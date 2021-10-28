// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakeExecutor {
    using SafeERC20 for IERC20;

    address internal stakingToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    /**
     * @dev transferFrom Staking Token (USDC) from staker to Stake contract if allowed
     * @param staker_ address of staker approved tokens to be transfered from its address
     * @param amount_ amount of tokens must be transfered to Stake contract
     */
    function _executeStake(
        address staker_,
        uint256 amount_
    ) internal {
        require(staker_ != address(0), "Zero address");
        require(amount_ > 0, "Zero amount");

        IERC20 _token = IERC20(stakingToken);
        require(_token.allowance(staker_, address(this)) >= amount_, "Insufficient allowance");
        _token.safeTransferFrom(staker_, address(this), amount_);
    }

    /**
     * @dev transfers Staking Token (USDC) from Stake contract to staker
     * @param staker_ address of staker tokens must be transfered to
     * @param amount_ amount of tokens must be transfered from Stake contract to staker
     */
    function _executeUnstake(
        address staker_,
        uint256 amount_
    ) internal {
        require(staker_ != address(0), "Zero address");
        require(amount_ > 0, "Zero amount");

        IERC20 _token = IERC20(stakingToken);
        _token.safeTransfer(staker_, amount_);
    }
}