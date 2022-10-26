// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProtocolFeeUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/ICollectible.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";

abstract contract Collectible721Upgradeable is
    ICollectible,
    BaseUpgradeable,
    ProtocolFeeUpgradeable,
    ERC721PermitUpgradeable,
    FundForwarderUpgradeable,
    ERC721EnumerableUpgradeable
{
    using SSTORE2 for bytes;
    using SSTORE2 for bytes32;
    using StringLib for uint256;
    using Bytes32Address for bytes32;
    using Bytes32Address for address;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    uint256 private constant __INDEX_BITS = 32;

    bytes32 public version;
    bytes32 private __baseTokenURIPtr;

    BitMapsUpgradeable.BitMap private __lockedTokens;
    mapping(uint256 => uint256) public typeIdTrackers;

    modifier notLocked(uint256 tokenId_) {
        __checkLock(tokenId_);
        _;
    }

    function updateTreasury(ITreasury treasury_)
        external
        onlyRole(Roles.OPERATOR_ROLE)
    {
        vault = address(treasury_);
    }

    function setBaseURI(string calldata baseURI_)
        external
        onlyRole(Roles.OPERATOR_ROLE)
    {
        _setBaseURI(baseURI_);
    }

    function lock(uint256 tokenId_) external notLocked(tokenId_) {
        if (ownerOf(tokenId_) != _msgSender())
            revert Collectible721__Unauthorized();
        __lockedTokens.set(tokenId_);

        emit Locked(tokenId_);
    }

    function unlock(uint256 tokenId_) external {
        if (ownerOf(tokenId_) != _msgSender())
            revert Collectible721__Unauthorized();
        __lockedTokens.unset(tokenId_);

        emit Unlocked(tokenId_);
    }

    function setFee(IERC20Upgradeable feeToken_, uint256 feeAmt_)
        external
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        if (!ITreasury(vault).supportedPayment(address(feeToken_)))
            revert Collectible__TokenNotSupported();
        _setRoyalty(feeToken_, uint96(feeAmt_));
    }

    function safeMint(address to_, uint256 typeId_)
        external
        whenNotPaused
        onlyRole(Roles.PROXY_ROLE)
    {
        unchecked {
            _safeMint(
                to_,
                (typeId_ << __INDEX_BITS) | typeIdTrackers[typeId_]++
            );
        }
    }

    function mint(address to_, uint256 typeId_)
        external
        override
        onlyRole(Roles.MINTER_ROLE)
    {
        unchecked {
            _mint(to_, (typeId_ << __INDEX_BITS) | typeIdTrackers[typeId_]++);
        }
    }

    function mintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external override onlyRole(Roles.MINTER_ROLE) {
        uint256 ptr = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                _mint(to_, ptr);
                ++ptr;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = ptr;
    }

    function safeMintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external override whenNotPaused onlyRole(Roles.PROXY_ROLE) {
        for (uint256 i; i < length_; ) {
            unchecked {
                _safeMint(to_, fromId_);
                ++fromId_;
                ++i;
            }
        }
    }

    function baseURI() external view returns (string memory) {
        return string(__baseTokenURIPtr.read());
    }

    function nextIdFromType(uint256 typeId_) public view returns (uint256) {
        return (typeId_ << __INDEX_BITS) | (typeIdTrackers[typeId_] + 1);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(__baseTokenURIPtr.read(), tokenId.toString())
            );
    }

    function isLocked(uint256 tokenId) public view returns (bool) {
        return __lockedTokens.get(tokenId);
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(
            ERC721Upgradeable,
            IERC165Upgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return
            type(IERC165Upgradeable).interfaceId == interfaceId_ ||
            super.supportsInterface(interfaceId_);
    }

    function _setBaseURI(string calldata baseURI_) internal {
        __baseTokenURIPtr = bytes(baseURI_).write();
    }

    function __Collectible_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_,
        ITreasury treasury_,
        bytes32 version_
    ) internal onlyInitializing {
        __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
        {
            IERC20Upgradeable[] memory payments = new IERC20Upgradeable[](1);
            payments[0] = feeToken_;
            treasury_.addPayments(payments);
        }
        __ERC721_init_unchained(name_, symbol_);
        __FundForwarder_init_unchained(address(treasury_));
        __Signable_init(type(Collectible721Upgradeable).name, "1");

        _setRoyalty(feeToken_, uint96(feeAmt_));

        __Collectible_init_unchained(baseURI_, version_);
    }

    function __Collectible_init_unchained(
        string calldata baseURI_,
        bytes32 version_
    ) internal onlyInitializing {
        version = version_;
        __baseTokenURIPtr = bytes(baseURI_).write();
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        _requireNotPaused();
        __checkLock(tokenId_);
        super._beforeTokenTransfer(from_, to_, tokenId_);

        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from_);
        _checkBlacklist(to_);

        if (
            from_ != address(0) &&
            to_ != address(0) &&
            !authority().hasRole(Roles.MINTER_ROLE, sender)
        ) {
            (IERC20Upgradeable feeToken, uint256 feeAmt) = feeInfo();

            _safeTransferFrom(feeToken, sender, vault, feeAmt);
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(__baseTokenURIPtr.read());
    }

    function __checkLock(uint256 tokenId_) private view {
        if (isLocked(tokenId_)) revert Collectible721__AlreadyLocked();
    }

    uint256[46] private __gap;
}
