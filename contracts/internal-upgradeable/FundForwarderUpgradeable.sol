// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/utils/ContextUpgradeable.sol";

import "./TransferableUpgradeable.sol";

import "./interfaces/IFundForwarderUpgradeable.sol";

abstract contract FundForwarderUpgradeable is
    ContextUpgradeable,
    TransferableUpgradeable,
    IFundForwarderUpgradeable
{
    bytes32 private _treasury;

    function __FundForwarder_init(ITreasuryV2 treasury_)
        internal
        onlyInitializing
    {
        __FundForwarder_init_unchained(treasury_);
    }

    function __FundForwarder_init_unchained(ITreasuryV2 treasury_) internal {
        _updateTreasury(treasury_);
    }

    receive() external payable virtual {
        address treasury_;
        assembly {
            treasury_ := sload(_treasury.slot)
        }
        _safeNativeTransfer(treasury_, msg.value);
    }

    function updateTreasury(ITreasuryV2) external virtual override;

    function treasury() public view returns (ITreasuryV2 treasury_) {
        assembly {
            treasury_ := sload(_treasury.slot)
        }
    }

    function _updateTreasury(ITreasuryV2 treasury_) internal {
        assembly {
            sstore(_treasury.slot, treasury_)
        }
    }

    uint256[49] private __gap;
}
