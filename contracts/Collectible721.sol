// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/AssetRoyaltyUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/ICollectible.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";

abstract contract Collectible721Upgradeable is
    ICollectible,
    BaseUpgradeable,
    AssetRoyaltyUpgradeable,
    ERC721PermitUpgradeable,
    FundForwarderUpgradeable,
    ERC721EnumerableUpgradeable
{
    using SSTORE2 for bytes;
    using SSTORE2 for bytes32;
    using StringLib for uint256;
    using Bytes32Address for bytes32;
    using Bytes32Address for address;

    bytes32 public version;
    bytes32 private _baseTokenURIPtr;

    function updateTreasury(ITreasuryV2 treasury_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    function setFee(IERC20Upgradeable feeToken_, uint256 feeAmt_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        if (!treasury().supportedPayment(feeToken_))
            revert Collectible__TokenNotSupported();
        _setfee(feeToken_, feeAmt_);
        emit FeeChanged();
    }

    function safeMint(address to_, uint256 tokenId_)
        external
        onlyRole(Roles.PROXY_ROLE)
    {
        address sender = _msgSender();
        _safeMint(sender, tokenId_);
        _transfer(sender, to_, tokenId_);
    }

    function mint(address to_, uint256 tokenId_)
        external
        override
        onlyRole(Roles.MINTER_ROLE)
    {
        _mint(to_, tokenId_);
    }

    function mintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external override onlyRole(Roles.MINTER_ROLE) {
        for (uint256 i; i < length_; ) {
            unchecked {
                _mint(to_, fromId_);
                ++fromId_;
                ++i;
            }
        }
        emit BatchMinted(to_, length_);
    }

    function safeMintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external override onlyRole(Roles.PROXY_ROLE) {
        address sender = _msgSender();
        for (uint256 i; i < length_; ) {
            unchecked {
                _safeMint(sender, fromId_);
                _transfer(sender, to_, fromId_);
                ++fromId_;
                ++i;
            }
        }
        emit BatchMinted(to_, length_);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_baseTokenURIPtr.read(), tokenId));
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

    function __Collectible_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_,
        bytes32 version_
    ) internal onlyInitializing {
        __Collectible_init_unchained(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            governance_,
            treasury_,
            version_
        );
    }

    function __Collectible_init_unchained(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_,
        bytes32 version_
    ) internal onlyInitializing {
        __Base_init(governance_, 0);
        __FundForwarder_init(treasury_);
        __ERC721_init(name_, symbol_);
        __EIP712_init(type(Collectible721Upgradeable).name, "2");

        version = version_;
        _setfee(feeToken_, feeAmt_);

        _baseTokenURIPtr = bytes(baseURI_).write();
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
        super._beforeTokenTransfer(from_, to_, tokenId_);

        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from_);
        _checkBlacklist(to_);

        if (
            from_ != address(0) &&
            to_ != address(0) &&
            !governance().hasRole(Roles.MINTER_ROLE, sender)
        ) {
            (IERC20Upgradeable feeToken, uint256 feeAmt) = feeInfo();
            _safeTransferFrom(feeToken, sender, address(treasury()), feeAmt);
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    uint256[48] private __gap;
}
