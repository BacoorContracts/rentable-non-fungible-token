// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {
    ERC20,
    ERC20Permit
} from "oz-custom/contracts/oz/token/ERC20/extensions/draft-ERC20Permit.sol";

contract ERC20Test is ERC20Permit {
    constructor()
        payable
        ERC20("PaymentToken", "PMT", 18)
        ERC20Permit("PaymentToken")
    {}

    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_ * 10**decimals);
    }
}
