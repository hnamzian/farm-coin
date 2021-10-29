// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract MockUSDC is ERC20PresetMinterPauser {
    constructor(uint256 totalSupply_)
        ERC20PresetMinterPauser("USDC Token", "USDC")
    {
        mint(msg.sender, totalSupply_);
    }
}
