// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./StakeStates.sol";
import "./StakeExecutor.sol";
import "../reward/ClaimReward.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BaseStake is StakeStates, StakeExecutor, ClaimReward {
    using Counters for Counters.Counter;

    uint256 internal _earlyWithdrawPunishmentRateX100 = 10;

    /**
     * @dev Staked Event will be raised at stake
     * @param lockupOption lockup option tokens staked
     * @param staker staker address
     * @param amount amount of tokens staked
     */
    event Staked(
        LockupOption indexed lockupOption,
        address indexed staker,
        uint256 amount
    );

    /**
     * @dev Unstaked Event will be raised at unstake
     * @param lockupOption lockup option tokens unstaked
     * @param user staker address
     * @param amount amount of tokens unstaked
     */
    event Unstaked(
        LockupOption indexed lockupOption,
        address indexed user,
        uint256 amount,
        uint256 punishment
    );

    /**
     * @dev will stake an amount of token to a specified lockup option
     * @param lockupOption_ the lockup option tokens to be staked
     * @param amount_ amount of tokens to be staked
     */
    function stake(LockupOption lockupOption_, uint256 amount_) public virtual {
        _beforeStake(lockupOption_, msg.sender, amount_);

        _updateStakes(lockupOption_, msg.sender, amount_);

        _afterStake(lockupOption_, msg.sender, amount_);

        emit Staked(lockupOption_, msg.sender, amount_);
    }

    /**
     * @dev will unstake an amount token from a specified lockup option
     * if not locked according to lock time
     * @param lockupOption_ lockup option tokens unstaked
     * @param amount_ amount of tokens to be unstaked
     */
    function unstake(LockupOption lockupOption_, uint256 amount_)
        public
        virtual
    {
        uint256 _unstakeableAmount = _beforeUnstake(lockupOption_, msg.sender, amount_);

        _unstake(lockupOption_, msg.sender, amount_);

        _afterUnstake(lockupOption_, msg.sender, _unstakeableAmount);
        emit Unstaked(lockupOption_, msg.sender, amount_, amount_ - _unstakeableAmount);
    }

    /**
     * @dev Internal method to implement core of staking an amount of token
     * to a specified lockup option by a specified staker
     * @param lockupOption_ lockup option tokens to be staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens to be staked
     */
    function _updateStakes(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal {
        require(amount_ > 0, "Zero amount");

        _appendToStakesHistory(lockupOption_, staker_, amount_);
        _increaseIndividualStakes(lockupOption_, staker_, amount_);
        _increaseTotalStakes(lockupOption_, amount_);
    }

    /**
     * @dev pre-processing routin before unstaking token
     * @param lockupOption_ lockup option tokens to be staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens to be staked
     */
    function _beforeStake(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal {
        claim();
    }

    /**
     * @dev post-processing routin after unstaking token
     * @param lockupOption_ lockup option tokens to be staked
     * @param staker_ address of staker
     * @param amount_ amount of tokens to be staked
     */
    function _afterStake(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal {
        _executeStake(staker_, amount_);
    }

    /**
     * @dev Internal method to implement core of unstaking an amount of token
     * from a specified lockup option by a specified staker
     * @param lockupOption_ the reward plan tokens to be unstaked
     * @param staker_ address of unstaker
     * @param amount_ amount of tokens to be unstaked
     */
    function _unstake(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal {
        require(
            stakesLockupOf(lockupOption_, staker_) >= amount_,
            "Insufficient stakes"
        );

        _decreaseIndividualStakes(lockupOption_, staker_, amount_);
        _decreaseTotalStakes(lockupOption_, amount_);
    }

    /**
     * @dev pre-processing routin before unstaking token
     * @dev calculate and process rewarding staker
     * @dev calculate unstakeable amount of tokens accordging to punishments
     * @param lockupOption_ the reward plan tokens will be unstaked
     * @param staker_ address of staker
     * @param amount_ amount of tokens has been unstaked
     * @return uint256 unstakeable amount
     */
    function _beforeUnstake(
        LockupOption lockupOption_,
        address staker_,
        uint256 amount_
    ) internal returns (uint256) {
        claim();

        // calculate unstakeable amount
        uint256 _unlockedAmount = _canUnstakeLockup(lockupOption_, staker_);
        uint256 _earlyWithdrawPunishment = ((amount_ - _unlockedAmount) *
            _earlyWithdrawPunishmentRateX100) / 100;
        uint256 unstakeableAmount_ = amount_ - _earlyWithdrawPunishment;

        return unstakeableAmount_;
    }

    /**
     * @dev post-processing routin after unstaking token
     * @param lockupOption_ the reward plan tokens will be unstaked
     * @param staker_ address of staker
     * @param unstakeableAmount_ amount of tokens to be unstaked
     */
    function _afterUnstake(
        LockupOption lockupOption_,
        address staker_,
        uint256 unstakeableAmount_
    ) internal {
        _executeUnstake(staker_, unstakeableAmount_);
    }

    /**
     * @dev returns amount of token staker can unstake now from a specified lockup option
     * @param lockupOption_ lockup option must be scanned for total amount can be unstaked
     * @param staker_ address of staker must be verified for total tokens permitted to unstake
     */
    function _canUnstakeLockup(LockupOption lockupOption_, address staker_)
        internal
        view
        returns (uint256 _unstakeables)
    {
        uint256 _stakesBalance = stakesLockupOf(lockupOption_, staker_);

        if (lockupOption_ == LockupOption.NO_LOCKUP) {
            return _stakesBalance;
        }

        Counters.Counter storage _stakeCounter = _stakeCounters[lockupOption_][
            staker_
        ];

        uint256 _toBeScannedStakes = _stakesBalance;
        uint256 _stakeIndex = _stakeCounter.current() - 1;

        while (_toBeScannedStakes > 0) {
            Stake memory _indexedStake = _stakesHistory[lockupOption_][staker_][
                _stakeIndex
            ];
            if (block.timestamp < _indexedStake.lockedUntil) {
                _toBeScannedStakes = _toBeScannedStakes > _indexedStake.amount
                    ? _toBeScannedStakes - _indexedStake.amount
                    : 0;
                _stakeIndex = _stakeIndex > 0 ? _stakeIndex - 1 : 0;
            } else {
                _unstakeables = _toBeScannedStakes;
                _toBeScannedStakes = 0;
            }
        }
    }
}
