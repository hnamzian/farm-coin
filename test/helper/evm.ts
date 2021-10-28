import { ethers } from "hardhat";

export class EVM {
  static increaseEVMTimestampAndMine = async (seconds: number) => {
    await ethers.provider.send("evm_increaseTime", [seconds]);
    await ethers.provider.send("evm_mine", []);
  };

  static increaseEVMTimestamp = async (seconds: number) => {
    await ethers.provider.send("evm_increaseTime", [seconds]);
  };
}