// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/utils/ContextUpgradeable.sol";

import "./interfaces/IAssetRoyaltyUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/oz-upgradeable/utils/math/SafeCastUpgradeable.sol";

abstract contract AssetRoyaltyUpgradeable is
    IAssetRoyaltyUpgradeable,
    ContextUpgradeable
{
    using Bytes32Address for uint256;
    using Bytes32Address for address;
    using SafeCastUpgradeable for uint256;

    uint256 private _feeInfo;

    function __AssetRoyalty_init() internal onlyInitializing {}

    function __AssetRoyalty_init_unchained() internal onlyInitializing {}

    function setFee(IERC20Upgradeable feeToken_, uint256 feeAmt_)
        external
        virtual
        override;

    function feeInfo()
        public
        view
        returns (IERC20Upgradeable feeToken, uint256 feeAmt)
    {
        uint256 fee = _feeInfo;
        feeToken = IERC20Upgradeable(fee.fromLast160Bits());
        feeAmt = fee & ~uint8(0);
    }

    function _setfee(IERC20Upgradeable feeToken_, uint256 feeAmt_) internal {
        _feeInfo = _packPayment(feeToken_, feeAmt_);
    }

    function _packPayment(IERC20Upgradeable token_, uint256 price_)
        internal
        pure
        returns (uint256)
    {
        return address(token_).fillFirst96Bits() | price_.toUint96();
    }

    uint256[49] private __gap;
}
