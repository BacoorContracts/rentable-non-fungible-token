// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "oz-custom/contracts/internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ITreasury is IWithdrawableUpgradeable {
    error Treasury__Expired();
    error Treasury__InvalidSignature();

    event PaymentAdded(IERC20Upgradeable indexed token);
    event PaymentRemoved(IERC20Upgradeable indexed token);
    event PaymentsAdded(IERC20Upgradeable[] indexed tokens);
    event SafeReceived(address indexed from, uint256 value);

    function supportedPayment(address token_) external view returns (bool);

    function withdraw(
        IERC20Upgradeable token_,
        address to_,
        uint256 amount_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function payments() external view returns (address[] memory);

    function addPayments(IERC20Upgradeable[] calldata tokens_) external;

    function removePayment(IERC20Upgradeable token_) external;
}
