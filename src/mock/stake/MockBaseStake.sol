// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "../../contracts/stake/BaseStake.sol";
import "./MockStakeExecutor.sol";

contract MockBaseStake is BaseStake, MockStakeExecutor {
    constructor(address stakingToken_) MockStakeExecutor(stakingToken_) {}
}
