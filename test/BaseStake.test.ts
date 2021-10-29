import { solidity } from "ethereum-waffle";
import chai from "chai";
import { ethers } from "hardhat";
import { parseUnits } from "@ethersproject/units";
import { Contract } from "@ethersproject/contracts";
import { default as random } from "random";
import { EVM } from "./helper/evm";

const { expect } = chai.use(solidity);

let baseStake: Contract, usdc: Contract;;

const DAY = 24 * 60 * 60;
const YEAR = 365 * DAY;

enum LockupOptions {
  NO_LOCKUP = 0,
  SIX_MOTH_LOCKUP = 1,
  ONE_YEAR_LOCKUP = 2
}
const lockupOptions = Object.keys(LockupOptions).filter((element) => !isNaN(Number(element)));
const lockupPeriods = [1, 180 * DAY, 1 * YEAR];

beforeEach(async () => {
  const ERC20 = await ethers.getContractFactory("MockUSDC");
  usdc = await ERC20.deploy(parseUnits("1000000"));

  const MockBaseStake = await ethers.getContractFactory("MockBaseStake");
  baseStake = await MockBaseStake.deploy(usdc.address);
})

describe("BaseStake", () => {
  it("should increase staked balance by staking token", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      const initOwnerBalance = await usdc.balanceOf(owner.address);
      const initFarmBalance = await usdc.balanceOf(baseStake.address);

      await usdc.approve(baseStake.address, stakeAmount);
      await baseStake.stake(lockupOption, stakeAmount);

      expect(
        await usdc.balanceOf(owner.address)
      ).to.be.eq(initOwnerBalance.sub(stakeAmount));
      expect(
        await usdc.balanceOf(baseStake.address)
      ).to.be.eq(initFarmBalance.add(stakeAmount));

      expect(
        await baseStake.stakesOf(owner.address)
      ).to.be.eq(totalStakesAmount);
      expect(
        await baseStake.stakesLockupOf(lockupOption, owner.address)
      ).to.be.eq(stakeAmount);
      expect(
        await baseStake.totalStakes()
      ).to.be.eq(totalStakesAmount);
      expect(
        await baseStake.totalStakesLockup(lockupOption)
      ).to.be.eq(stakeAmount);
    }
  })

  it("should return tokens and decrease stake balance at unstake", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      const initOwnerBalance = await usdc.balanceOf(owner.address);
      const initFarmBalance = await usdc.balanceOf(baseStake.address);

      await usdc.approve(baseStake.address, stakeAmount);
      await baseStake.stake(lockupOption, stakeAmount);

      await EVM.increaseEVMTimestampAndMine(lockupPeriods[lockupOption]);

      await baseStake.unstake(lockupOption, stakeAmount);

      expect(
        await usdc.balanceOf(owner.address)
      ).to.be.eq(initOwnerBalance);
      expect(
        await usdc.balanceOf(baseStake.address)
      ).to.be.eq(initFarmBalance);

      expect(
        await baseStake.stakesOf(owner.address)
      ).to.be.eq(0);
      expect(
        await baseStake.stakesLockupOf(lockupOption, owner.address)
      ).to.be.eq(0);
      expect(
        await baseStake.totalStakes()
      ).to.be.eq(0);
      expect(
        await baseStake.totalStakesLockup(lockupOption)
      ).to.be.eq(0);
    }
  })

  it("should return charge user with 10% punishment for early unstake", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      const initOwnerBalance = await usdc.balanceOf(owner.address);
      const initFarmBalance = await usdc.balanceOf(baseStake.address);

      await usdc.approve(baseStake.address, stakeAmount);
      await baseStake.stake(lockupOption, stakeAmount);

      await EVM.increaseEVMTimestamp(lockupPeriods[lockupOption] - 1);

      await baseStake.unstake(lockupOption, stakeAmount);

      const punishment = +lockupOption == LockupOptions.NO_LOCKUP ?
        ethers.BigNumber.from(0) :
        stakeAmount.mul(10).div(100);

      expect(
        await usdc.balanceOf(owner.address)
      ).to.be.eq(initOwnerBalance.sub(punishment));
      expect(
        await usdc.balanceOf(baseStake.address)
      ).to.be.eq(initFarmBalance.add(punishment));

      expect(
        await baseStake.stakesOf(owner.address)
      ).to.be.eq(0);
      expect(
        await baseStake.stakesLockupOf(lockupOption, owner.address)
      ).to.be.eq(0);
      expect(
        await baseStake.totalStakes()
      ).to.be.eq(0);
      expect(
        await baseStake.totalStakesLockup(lockupOption)
      ).to.be.eq(0);
    }
  })
})
describe("BaseStake Events", () => {
  it("should emit events when user staked tokens", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      await usdc.approve(baseStake.address, stakeAmount);

      await expect(baseStake.stake(lockupOption, stakeAmount))
        .to
        .emit(baseStake, "Staked")
        .withArgs(+lockupOption, owner.address, stakeAmount);
    }
  })

  it("should emit events when user unstaked tokens", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      await usdc.approve(baseStake.address, stakeAmount);
      await baseStake.stake(lockupOption, stakeAmount);

      await EVM.increaseEVMTimestampAndMine(lockupPeriods[lockupOption]);

      await expect(baseStake.unstake(lockupOption, stakeAmount))
        .to
        .emit(baseStake, "Unstaked")
        .withArgs(+lockupOption, owner.address, stakeAmount, 0);
    }
  })

  it("should emit events when user unstaked tokens", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      await usdc.approve(baseStake.address, stakeAmount);
      await baseStake.stake(lockupOption, stakeAmount);

      await EVM.increaseEVMTimestamp(lockupPeriods[lockupOption] - 1);

      const punishment = +lockupOption == LockupOptions.NO_LOCKUP ?
        ethers.BigNumber.from(0) :
        stakeAmount.mul(10).div(100);

      await expect(baseStake.unstake(lockupOption, stakeAmount))
        .to
        .emit(baseStake, "Unstaked")
        .withArgs(+lockupOption, owner.address, stakeAmount, punishment);
    }
  })
})