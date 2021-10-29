// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RewardStates.sol";
import "../stake/StakeStates.sol";

contract RewardCalculator is RewardStates, StakeStates {
    /**
     * @dev (lockupOption => rewardRate)
     * determines reward rate assigned to each lockup option
     */
    mapping(LockupOption => uint8) internal _rewardRates;

    // base period reward rate assigned
    uint256 internal _rewardRatePeriod = 365 days;

    constructor() {
        _setRewardRate(LockupOption.NO_LOCKUP, 10);
        _setRewardRate(LockupOption.SIX_MOTH_LOCKUP, 20);
        _setRewardRate(LockupOption.ONE_YEAR_LOCKUP, 30);
    }

    /**
     * @dev returns reward rate assigned for each lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @return reward rate
     */
    function rewardRate(LockupOption lockupOption_)
        public
        view
        returns (uint256)
    {
        return _rewardRates[lockupOption_];
    }

    /**
     * @dev sets reward rate to a specified lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param rewardRate_ reward rate
     */
    function _setRewardRate(LockupOption lockupOption_, uint8 rewardRate_)
        internal
    {
        _rewardRates[lockupOption_] = rewardRate_;
    }

    /**
     * @dev calculate rewards of a specified rewardee for tokens staked
     * in a specified lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param rewardee_ address of rewardee
     * @return amount of rewards
     */
    function _calculateRewardsOf(LockupOption lockupOption_, address rewardee_)
        internal
        view
        returns (uint256)
    {
        uint256 _stakesOf = stakesLockupOf(lockupOption_, rewardee_);
        uint256 _lastTimeRewarded = lastTimeRewardedTo(
            lockupOption_,
            rewardee_
        );

        return _calculateRewards(lockupOption_, _stakesOf, _lastTimeRewarded);
    }

    /**
     * @dev helper function to calculate rewards geiven lockup option, stakes amount,
     * last time rewarded
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param stakes_ amount of tokens staked by an account in the lockup option
     * @param lastTimeRewarded_ latest time account rewarded
     * @return amount of rewards
     */
    function _calculateRewards(
        LockupOption lockupOption_,
        uint256 stakes_,
        uint256 lastTimeRewarded_
    ) private view returns (uint256) {
        if (stakes_ == 0) {
            return 0;
        }
        
        uint256 _timePassed = block.timestamp - lastTimeRewarded_;

        return
            (stakes_ * _timePassed * uint256(rewardRate(lockupOption_))) /
            (100 * _rewardRatePeriod);
    }
}
