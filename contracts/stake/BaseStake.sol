// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./StakeStates.sol";
import "./StakeExecutor.sol";

contract BaseStake is StakeStates, StakeExecutor {
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
     * @dev will stake an amount of token to a specified lockup option
     * @param lockupOption_ the lockup option tokens to be staked
     * @param amount_ amount of tokens to be staked
     */
    function stake(
        LockupOption lockupOption_,
        uint256 amount_
    ) public virtual {
        _beforeStake(lockupOption_, msg.sender, amount_);

        _updateStakes(lockupOption_, msg.sender, amount_);

        _afterStake(lockupOption_, msg.sender, amount_);

        emit Staked(lockupOption_, msg.sender, amount_);
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
    ) internal {}

    /**
     * @dev post-processing routin before unstaking token
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
}