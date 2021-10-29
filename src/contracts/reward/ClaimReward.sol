// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RewardCalculator.sol";

contract ClaimReward is RewardCalculator {
    event Rewarded(LockupOption indexed, address indexed, uint256);

    /**
     * @dev assign amount of tokens must be rewarded to a specified rewardee
     * according to its stakes at a specified lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param rewardee_ account address of rewardee
     */
    function _reward(LockupOption lockupOption_, address rewardee_)
        internal
        virtual
        returns (uint256 _rewardsOf)
    {
        require(rewardee_ != address(0), "Zero address");

        _rewardsOf = _calculateRewardsOf(lockupOption_, rewardee_);

        _increaseTotalRewardsOf(lockupOption_, rewardee_, _rewardsOf);
        _increaseTotalRewards(lockupOption_, _rewardsOf);
        _updateLastTimeRewardedTo(lockupOption_, rewardee_);

        emit Rewarded(lockupOption_, rewardee_, _rewardsOf);
    }

    /**
     * @dev assign amount of tokens must be rewarded to reward claimee
     * according to its stakes at all lockup options
     */
    function claim() public {
        uint8 _lockupOption;
        for (
            _lockupOption = uint8(LockupOption.NO_LOCKUP);
            _lockupOption <= uint8(LockupOption.ONE_YEAR_LOCKUP);
            _lockupOption++
        ) {
            _reward(LockupOption(_lockupOption), msg.sender);
        }
    }
}
