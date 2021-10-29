import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "@ethersproject/contracts";

let lockup: Contract;

enum LockupupOptions {
  NO_LOCKUP,
  SIX_MOTH_LOCKUP,
  ONE_YEAR_LOCKUP
}

const DAY = 24 * 60 * 60;
const YEAR = 365 * DAY;

beforeEach(async () => {
  const LockupPeriod = await ethers.getContractFactory("LockupPeriod");
  lockup = await LockupPeriod.deploy();
})

describe("LockupPeriod", () => {
  it("should return lockup periods", async () => {
    expect(
      await lockup.lockupPeriod(LockupupOptions.NO_LOCKUP)
    ).to.be.equal(0)
    expect(
      await lockup.lockupPeriod(LockupupOptions.SIX_MOTH_LOCKUP)
    ).to.be.equal(180 * DAY)
    expect(
      await lockup.lockupPeriod(LockupupOptions.ONE_YEAR_LOCKUP)
    ).to.be.equal(1 * YEAR)
  })
})