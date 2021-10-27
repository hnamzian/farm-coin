// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./stake/BaseStake.sol";
import "./reward/ClaimReward.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FarmCoin is ERC20, ClaimReward, BaseStake {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}

    function _reward(LockupOption lockupOption_, address rewardee_)
        internal
        virtual
        override
        returns (uint256 _rewardsOf)
    {
        _rewardsOf = super._reward(lockupOption_, rewardee_);

        _mint(rewardee_, _rewardsOf);
    }
}
