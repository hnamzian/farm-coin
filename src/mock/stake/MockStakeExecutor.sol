// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "../../contracts/stake/StakeExecutor.sol";

contract MockStakeExecutor is StakeExecutor {
    constructor(address stakingToken_) {
        _stakingToken = stakingToken_;
    }
}