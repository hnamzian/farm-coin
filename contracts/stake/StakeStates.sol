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
}
