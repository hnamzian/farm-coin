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
     * @param lockupOption_ lockup option to which which can be: (NO_LOCKUP, SIX_MONTH_LOCKUP, ONE_YEAR_LOCKUP)
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
    function totalStakes() public view returns (uint256 _totalStaked) {
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
     * @param lockupOption_ lockup option to which which can be: (NO_LOCKUP, SIX_MONTH_LOCKUP, ONE_YEAR_LOCKUP)
     * @param staker_ address of staker
     * @return uint256 total amount of tokens staked to a specified lockup optin by the staker
     */
    function stakesLockupOf(LockupOption lockupOption_, address staker_)
        public
        view
        returns (uint256)
    {
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

    /**
     * @dev increases total amount of tokens has been staked by an address
     * to a specified lockup option
     * @param lockupOption the lockup option to which tokens staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens must be added to staker's total staked amount
     * of a specified lockup option
     */
    function _increaseIndividualStakes(
        LockupOption lockupOption,
        address staker_,
        uint256 amount_
    ) internal {
        _stakes[lockupOption][staker_] =
            _stakes[lockupOption][staker_] +
            amount_;
    }

    /**
     * @dev decreases total amount of tokens has been staked by an address
     * to a specified lockup option
     * @param lockupOption the lockup option to which tokens staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens must be subtracted from staker's total staked amount
     * of a specified lockup option
     */
    function _decreaseIndividualStakes(
        LockupOption lockupOption,
        address staker_,
        uint256 amount_
    ) internal {
        _stakes[lockupOption][staker_] =
            _stakes[lockupOption][staker_] -
            amount_;
    }

    /**
     * @dev increases total amount of tokens has been staked by all address
     * to a specified lockup option
     * @param lockupOption the lockup option to which tokens staked
     * @param amount_ amount of tokens must be added to total staked amount
     * of a specified lockup option
     */
    function _increaseTotalStakes(LockupOption lockupOption, uint256 amount_)
        internal
    {
        _totalStakes[lockupOption] = _totalStakes[lockupOption] + amount_;
    }

    /**
     * @dev increases total amount of specified LP tokens has been staked by all address
     * to a specified lockup option
     * @param lockupOption the lockup option to which tokens staked
     * @param amount_ amount of tokens must be subtracted from total staked amount
     * of a specified lockup option
     */
    function _decreaseTotalStakes(LockupOption lockupOption, uint256 amount_)
        internal
    {
        _totalStakes[lockupOption] = _totalStakes[lockupOption] - amount_;
    }

    /**
     * @dev inserts a new Stake object to StakeHistory of a specified staker address list,
     * and updating StakesCounter
     * @param lockupOption_ the lockup option tokens staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens staked by staker
     */
    function _appendToStakesHistory(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal {
        Counters.Counter storage _counter = _stakeCounters[lockupOption_][
            msg.sender
        ];

        uint256 _stakeIndex = _counter.current();

        _counter.increment();

        _stakesHistory[lockupOption_][staker_][_stakeIndex] = Stake(
            amount_,
            block.timestamp,
            block.timestamp + lockupPeriod(lockupOption_)
        );
    }
}
