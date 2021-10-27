// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    /**
     * @dev returns total tokens rewarded to addresses staked tokens
     * @param lockupOption_ uint8 representing Reward lockup option
     * @return total rewards paid for tokens staked to a specified lockup option
     */
    function totalRewardsLockupOption(LockupOption lockupOption_)
        public
        view
        returns (uint256)
    {
        return _totalRewards[lockupOption_];
    }

    /**
     * @dev returns total tokens rewarded to addresses staked
     * tokens to a specified lockup option
     * @return _rewards total rewards paid for tokens staked
     */
    function totalRewards() public view returns (uint256 _rewards) {
        uint8 _lockupOption;
        for (
            _lockupOption = uint8(LockupOption.NO_LOCKUP);
            _lockupOption <= uint8(LockupOption.ONE_YEAR_LOCKUP);
            _lockupOption++
        ) {
            _rewards += totalRewardsLockupOption(LockupOption(_lockupOption));
        }
    }

    /**
     * @dev returns total tokens rewarded to a specified rewardee_ staked
     * tokens to a specified lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param rewardee_ address of one's been rewarded
     * @return total rewards paid for tokens staked to lockup option by reardee_
     */
    function totalRewardsOfLockupOption(
        LockupOption lockupOption_,
        address rewardee_
    ) public view returns (uint256) {
        return _totalRewardsOf[lockupOption_][rewardee_];
    }

    /**
     * @dev returns total tokens rewarded to a specified rewardee_ staked tokens
     * @param rewardee_ address of one's been rewarded
     * @return _rewards total rewards paid for tokens staked to lockup option by reardee_
     */
    function totalRewardsOf(address rewardee_)
        public
        view
        returns (uint256 _rewards)
    {
        uint8 _lockupOption;
        for (
            _lockupOption = uint8(LockupOption.NO_LOCKUP);
            _lockupOption <= uint8(LockupOption.ONE_YEAR_LOCKUP);
            _lockupOption++
        ) {
            _rewards += totalRewardsOfLockupOption(
                LockupOption(_lockupOption),
                rewardee_
            );
        }
    }

    /**
     * @dev increases total amount of tokens rewarded for tokens
     * staked to a specified lockup option
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param amount_ amount of tokens recently rewarded
     */
    function _increaseTotalRewards(
        LockupOption lockupOption_,
        uint256 amount_
    ) internal {
        _totalRewards[lockupOption_] += amount_;
    }

    /**
     * @dev increases total amount of tokens rewarded for tokens
     * staked to a specified lockup option to specified rewardee_
     * @param lockupOption_ uint8 representing Reward lockup option
     * @param rewardee_ address of one's been rewarded
     * @param amount_ amount of tokens recently rewarded
     */
    function _increaseTotalRewardsOf(
        LockupOption lockupOption_,
        address rewardee_,
        uint256 amount_
    ) internal {
        _totalRewardsOf[lockupOption_][rewardee_] += amount_;
    }
}
