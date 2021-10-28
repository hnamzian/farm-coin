import { expect } from "chai";
import { ethers } from "hardhat";
import { formatUnits, parseUnits } from "@ethersproject/units";
import { Contract } from "@ethersproject/contracts";
import { default as random } from "random";
import { EVM } from "./helper/evm"

let farmCoin: Contract, usdc: Contract;;

const DAY = 24 * 60 * 60;
const YEAR = 365 * DAY;

enum LockupOptions {
  NO_LOCKUP = 0,
  SIX_MOTH_LOCKUP = 1,
  ONE_YEAR_LOCKUP = 2
}
const lockupOptions = Object.keys(LockupOptions).filter((element) => !isNaN(Number(element)));
const lockupPeriods = [1, 180 * DAY, 1 * YEAR];
const rewardRates = [10, 20, 30];

beforeEach(async () => {
  const ERC20 = await ethers.getContractFactory("MockUSDC");
  usdc = await ERC20.deploy(parseUnits("1000000"));

  const MockFarmCoin = await ethers.getContractFactory("MockFarmCoin");
  farmCoin = await MockFarmCoin.deploy("FarmCoin Token", "FCT", usdc.address);
})

describe("FarmCoin", () => {
  it("should reward staker at each stake/unstake", async () => {
    const [owner] = await ethers.getSigners();

    let totalStakesAmount = ethers.BigNumber.from(0);
    for (const lockupOption in lockupOptions) {
      const stakeAmount = parseUnits(random.int(1000, 10000).toString());

      totalStakesAmount = totalStakesAmount.add(stakeAmount);

      const fctInitOwnerBalance = await farmCoin.balanceOf(owner.address);

      await usdc.approve(farmCoin.address, stakeAmount);
      await farmCoin.stake(lockupOption, stakeAmount);

      const depositPeriod = 1 * YEAR;
      await EVM.increaseEVMTimestamp(depositPeriod);

      await farmCoin.unstake(lockupOption, stakeAmount);

      const rewards = stakeAmount
        .mul(rewardRates[lockupOption])
        .mul(ethers.BigNumber.from(depositPeriod))
        .div(ethers.BigNumber.from(100))
        .div(ethers.BigNumber.from(1 * YEAR));

      expect(await farmCoin.balanceOf(owner.address)).to.be.eq(fctInitOwnerBalance.add(rewards))
    }
  })
})