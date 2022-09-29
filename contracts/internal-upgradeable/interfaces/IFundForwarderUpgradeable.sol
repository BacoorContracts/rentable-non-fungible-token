// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../../interfaces/ITreasuryV2.sol";

interface IFundForwarderUpgradeable {
    event TreasuryUpdated(ITreasuryV2 indexed from, ITreasuryV2 indexed to);

    function updateTreasury(ITreasuryV2 treasury_) external;
}
