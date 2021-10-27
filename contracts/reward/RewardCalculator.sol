// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lockup/LockupPeriod.sol";

contract RewardCalculator is LockupPeriod {
    /**
     * @dev (lockupOption => rewardRate)
     * determines reward rate assigned to each lockup option
     */
    mapping(LockupOption => uint8) internal _rewardRates;

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
}
