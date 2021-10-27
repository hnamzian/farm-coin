// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "../lockup/LockupPeriod.sol";

contract RewardStates is LockupPeriod {
    /**
     * @dev (lockupOption => rewardee => rewards)
     * determines total amount of tokens rewarded to rewardee for tokens
     * staked to each of lockup option
     */
    mapping(LockupOption => mapping(address => uint256))
        internal _totalRewardsOf;

    /**
     * @dev (lockupOption => rewards)
     * determines total amount of tokens rewarded to all rewardees for their
     * stakes to each lockup option
     */
    mapping(LockupOption => uint256) internal _totalRewards;
}