// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../contracts/FarmCoin.sol";
import "./stake/MockBaseStake.sol";
import "../contracts/reward/ClaimReward.sol";

contract MockFarmCoin is FarmCoin, MockBaseStake {
    constructor(
        string memory name_,
        string memory symbol_,
        address stakingToken_
    ) FarmCoin(name_, symbol_) MockBaseStake(stakingToken_) {}

    function _reward(LockupOption lockupOption_, address rewardee_)
        internal
        virtual
        override(FarmCoin, ClaimReward)
        returns (uint256 _rewardsOf)
    {
        return super._reward(lockupOption_, rewardee_);
    }
}
