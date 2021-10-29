# FarmCoin
FarmCoin is a smart contract which accepts USDC deposits and pays out interest in the form of a new ERC20 called FarmCoin. The interest rate is determined by how long a user agrees to lock up their USDC deposit. If the user wishes to unlock their tokens early, they should be able to withdraw them for a 10% fee.

Functionality:
- A contract that accepts USDC deposits and rewards the user with FarmCoins
- If there is no lock up period, the user should earn 10% APY in FarmCoin
- For a six month lock up, the user should earn 20% APY in FarmCoin
- For a 1 year lock up, the user should earn 30% APY in FarmCoin
- For example, if a user deposits 100 USDC with no lockup, their deposit should begin accruing interest immediately, at a rate of 10 FarmCoins per year.
- If the user locks up their USDC for higher returns, they should be able to withdraw them early for a 10% fee on the original USDC deposit.


# Advanced Sample Hardhat Project

This project demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.template file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
