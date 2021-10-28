import { expect } from "chai";
import { ethers } from "hardhat";
import { formatUnits, parseUnits } from "@ethersproject/units";
import { Contract } from "@ethersproject/contracts";
import { default as random } from "random";
import {
  lockupOptions,
  LockupOptions,
  rewardRates,
  Staker,
  YEAR } from "./helper/FarmCoin"
import { EVM } from "./helper/evm";

let farmCoin: Contract, usdc: Contract;;

beforeEach(async () => {
  const ERC20 = await ethers.getContractFactory("MockUSDC");
  usdc = await ERC20.deploy(parseUnits("1000000"));

  const MockFarmCoin = await ethers.getContractFactory("MockFarmCoin");
  farmCoin = await MockFarmCoin.deploy("FarmCoin Token", "FCT", usdc.address);
})

describe("FarmCoin", () => {
  it("should reward staker at each stake/unstake", async () => {
    const [owner] = await ethers.getSigners();

    const fctInitOwnerBalance = await farmCoin.balanceOf(owner.address);
    
    const staker = new Staker();

    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      await usdc.approve(farmCoin.address, stakeAmount);
      await farmCoin.stake(lockupOption, stakeAmount);

      // simulate staking
      staker.stake(+lockupOption, stakeAmount);

      const depositPeriod = 1 * YEAR;
      await EVM.increaseEVMTimestamp(depositPeriod);

      await farmCoin.unstake(lockupOption, stakeAmount);

      // calculate desired rewards
      await staker.unstake(+lockupOption, stakeAmount);

      expect(
        await farmCoin.totalRewardsOfLockupOption(lockupOption, owner.address)
      ).to.be.eq(staker.totalRewardsLockup(+lockupOption));
      expect(
        await farmCoin.totalRewardsOf(owner.address)
      ).to.be.eq(staker.totalRewards());

      expect(
        await farmCoin.balanceOf(owner.address)
      ).to.be.eq(fctInitOwnerBalance.add(staker._totalRewards))
    }
  })

})