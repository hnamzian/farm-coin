// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "../lockup/LockupPeriod.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * StakingStates contains states reflecting amount of tokens
 * staked. It provides basic getter functions can be used for queries
 * to reach reports, like total staked amount per user and tier and overall
 * statistics.
 */
contract StakeStates is LockupPeriod {
    using Counters for Counters.Counter;

    /**
     * @dev Stake struct containing basic info of every single stake
     * @param amount uint256 param determines amount of token staked by an address
     * @param lockedUntil uint256 timestamp determines until when tokens are unstakeable
     */
    struct Stake {
        uint256 amount;
        uint256 stakedAt;
        uint256 lockedUntil;
    }

    /**
     * @dev (lockupOption => staker => stakeIndex => Stake)
     * @dev stores list of staking data at each LockupOption by an address
     */
    mapping(LockupOption => mapping(address => mapping(uint256 => Stake)))
        internal _stakesHistory;

    /**
     * @dev (lockupOption => staked => counter)
     * @dev stores times each address has staked tokens to each of LockupOptions
     */
    mapping(LockupOption => mapping(address => Counters.Counter))
        internal _stakeCounters;

    /**
     * @dev (lockupOption => staker => amount)
     * @dev total amount of stakes held by each address to each LockupOption
     */
    mapping(LockupOption => mapping(address => uint256)) internal _stakes;

    /**
     * @dev (lockupOption => amount)
     * @dev total amount of stakes held by all address at each LockupOption
     */
    mapping(LockupOption => uint256) internal _totalStakes;


    /**
     * @dev returns total staked amount of tokens to a specified lockup optin by all addresses
     * @param lockupOption_ reward plan which can be: (NO_LOCKUP, SIX_MONTH_LOCKUP, ONE_YEAR_LOCKUP)
     * @return uint256 total amount of tokens staked to lockupOption_
     */
    function totalStakesLockup(LockupOption lockupOption_)
        public
        view
        returns (uint256)
    {
        return _totalStakes[lockupOption_];
    }

    /**
     * @dev returns total staked amount of tokens over all lockup optins by all addresses
     * @return _totalStaked uint256 total amount of tokens staked over all lockup optins by all addresses
     */
    function totalStakes()
        public
        view
        returns (uint256 _totalStaked)
    {
        uint8 _lockupOption;
        for (
            _lockupOption = uint8(LockupOption.NO_LOCKUP);
            _lockupOption <= uint8(LockupOption.ONE_YEAR_LOCKUP);
            _lockupOption++
        ) {
            _totalStaked += totalStakesLockup(LockupOption(_lockupOption));
        }
    }

    /**
     * @dev returns total staked amount of tokens to a specified lockup optin by a specified address
     * @param lockupOption_ reward plan which can be: (NO_LOCKUP, SIX_MONTH_LOCKUP, ONE_YEAR_LOCKUP)
     * @param staker_ address of staker
     * @return uint256 total amount of tokens staked to a specified lockup optin by the staker
     */
    function stakesLockupOf(
        LockupOption lockupOption_,
        address staker_
    ) public view returns (uint256) {
        return _stakes[lockupOption_][staker_];
    }

    /**
     * @dev returns total staked amount of tokens over all lockup optins by a specified address
     * @param staker_ address of staker
     * @return _totalStakesOf uint256 total amount of tokens staked over all lockup optins by the staker
     */
    function stakesOf(address staker_)
        public
        view
        returns (uint256 _totalStakesOf)
    {
        uint8 _lockupOption;
        for (
            _lockupOption = uint8(LockupOption.NO_LOCKUP);
            _lockupOption <= uint8(LockupOption.ONE_YEAR_LOCKUP);
            _lockupOption++
        ) {
            _totalStakesOf += stakesLockupOf(
                LockupOption(_lockupOption),
                staker_
            );
        }
    }
}
