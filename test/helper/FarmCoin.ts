import { ethers } from "ethers";
import { EVM } from "./evm";

export const DAY = 24 * 60 * 60;
export const YEAR = 365 * DAY;

export enum LockupOptions {
  NO_LOCKUP = 0,
  SIX_MOTH_LOCKUP = 1,
  ONE_YEAR_LOCKUP = 2
};

export const lockupOptions = Object.keys(LockupOptions).filter((element) => !isNaN(Number(element)));

export const lockupPeriods = [1, 180 * DAY, 1 * YEAR];

export const rewardRates = [
  ethers.BigNumber.from(10),
  ethers.BigNumber.from(20),
  ethers.BigNumber.from(30)
];

export class Staker {
  _stakes = [
    ethers.BigNumber.from(0),
    ethers.BigNumber.from(0),
    ethers.BigNumber.from(0),
  ];

  _rewards = [
    ethers.BigNumber.from(0),
    ethers.BigNumber.from(0),
    ethers.BigNumber.from(0),
  ];

  _totalRewards = ethers.BigNumber.from(0);

  _lastTimeRewarded = [0, 0, 0];

  stake = async (lockupOption: LockupOptions, amount: ethers.BigNumber) => {
    await this.updateRewardsLockup(lockupOption);
    this._stakes[lockupOption] = this._stakes[lockupOption].add(amount);
  }

  unstake = async (lockupOption: LockupOptions, amount: ethers.BigNumber) => {   
    await this.updateRewardsLockup(lockupOption);
    this._stakes[lockupOption] = this._stakes[lockupOption].sub(amount);
  }

  updateRewardsLockup = async (lockupOption: LockupOptions) => {
    const timestamp = await EVM.getTimestamp();
    const timePassed = timestamp - this._lastTimeRewarded[lockupOption];
    
    const additiveRewards = this._stakes[lockupOption]
      .mul(rewardRates[lockupOption])
      .mul(ethers.BigNumber.from(timePassed))
      .div(ethers.BigNumber.from(100))
      .div(ethers.BigNumber.from(1 * YEAR));
        
    this._rewards[lockupOption] = this._rewards[lockupOption].add(additiveRewards);

    this._totalRewards = this._totalRewards.add(additiveRewards);

    this._lastTimeRewarded[lockupOption] = timestamp;

    return this._rewards[lockupOption];
  }

  updateRewards = async () => {
    await Promise.all(
      lockupOptions.map(async lockupOption => await this.updateRewardsLockup(+lockupOption))
    );
    return this._totalRewards;
  }

  totalRewardsLockup = (lockupOption: LockupOptions) => {
    return this._rewards[lockupOption];
  }

  totalRewards = () => {
    return this._totalRewards;
  }
}