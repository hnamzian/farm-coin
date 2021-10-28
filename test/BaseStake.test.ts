import { expect } from "chai";
import { ethers } from "hardhat";
import { parseUnits } from "@ethersproject/units";
import { Contract } from "@ethersproject/contracts";
import { default as random } from "random";

let baseStake: Contract, usdc: Contract;;

enum LockupupOptions {
  NO_LOCKUP = 0,
  SIX_MOTH_LOCKUP = 1,
  ONE_YEAR_LOCKUP = 2
}
const lockupOptions = Object.keys(LockupupOptions).filter((element) => !isNaN(Number(element)));

const DAY = 24 * 60 * 60;
const YEAR = 365 * DAY;

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
      const stakeAmount = parseUnits(random.int(1000, 2000).toString());

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
})