// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * LockupPeriod contract defines periods of staking options.
 * There are three lockup options for staking:
 *  - NO_LOCKUP
 *  - SIX_MOTH_LOCKUP
 *  - ON_YEAR_LOCKUP
 * One cannot withdraw before lockup period reaches unless will
 * be punished by 10%.
 * Longer lockup period staking will yield more reward rates.
 */
contract LockupPeriod {
    enum LockupOption {
        NO_LOCKUP,
        SIX_MOTH_LOCKUP,
        ONE_YEAR_LOCKUP
    }

    mapping(LockupOption => uint256) internal _lockupPeriod;

    constructor() {
        _setLockupPeriod(LockupOption.NO_LOCKUP, 0);
        _setLockupPeriod(LockupOption.SIX_MOTH_LOCKUP, 180 days);
        _setLockupPeriod(LockupOption.ONE_YEAR_LOCKUP, 365 days);
    }

    function lockupPeriod(LockupOption lockupOption_)
        public
        view
        returns (uint256)
    {
        return _lockupPeriod[lockupOption_];
    }

    function _setLockupPeriod(LockupOption lockupOption_, uint256 period_)
        private
    {
        _lockupPeriod[lockupOption_] = period_;
    }
}
