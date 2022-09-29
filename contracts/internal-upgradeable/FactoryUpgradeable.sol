// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/utils/ContextUpgradeable.sol";

import "./interfaces/IFactoryUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/libraries/EnumerableSet256.sol";
import "oz-custom/contracts/oz-upgradeable/proxy/ClonesUpgradeable.sol";

abstract contract FactoryUpgradeable is
    ContextUpgradeable,
    IFactoryUpgradeable
{
    using Bytes32Address for address;
    using Bytes32Address for bytes32;
    using ClonesUpgradeable for address;
    using EnumerableSet256 for EnumerableSet256.AddressSet;

    ///@dev value is equal to keccak256("Factory_v1")
    bytes32 public constant VERSION =
        0x14157cddfd989cb73bdcdfaaac09eec95dba7447e30c28fe22497d7217730bce;

    bytes32 internal _implement;
    EnumerableSet256.AddressSet internal _clones;

    function __Factory_init(address implement_) internal onlyInitializing {
        __Factory_init_unchained(implement_);
    }

    function __Factory_init_unchained(address implement_)
        internal
        onlyInitializing
    {
        _setImplement(implement_);
    }

    function clones() external view returns (address[] memory) {
        return _clones.values();
    }

    function implement() external view returns (address) {
        return _implement.fromFirst20Bytes();
    }

    function _setImplement(address implement_) internal {
        _implement = implement_.fillLast12Bytes();
    }

    function _cheapClone(
        bytes32 salt_,
        bytes4 interfaceId_,
        bytes4 selector_,
        bytes memory args_
    ) internal returns (address clone_) {
        address implement_ = _implement.fromFirst20Bytes();
        clone_ = implement_.cloneDeterministic(salt_);
        (bool ok, ) = clone_.call(abi.encodePacked(selector_, args_));
        if (!ok) revert Factory__CloneFailed();
        _clones.add(clone_);
        emit NewInstance(implement_, clone_, salt_, interfaceId_);
    }

    uint256[48] private __gap;
}
