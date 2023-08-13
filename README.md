# GodCoin Smart Contracts

This repository contains the source code for the GodCoin smart contracts, comprising two main contracts: `GodCoinV1` and `GodCoinV2`. These contracts implement a token system with various functionalities, including minting and burning tokens, transferring tokens with fees, token approvals, and more.

## Contracts Overview

### `GodCoinV1`

This contract represents the initial version of the GodCoin token. It features functions for minting and burning tokens, transferring tokens with fees, managing token approvals, and handling blacklisted accounts.

### `GodCoinV2`

This contract represents an upgraded version of the GodCoin token. It retains the functionalities of `GodCoinV1` and adds new features or improvements.

## Key Features

- Mint and Burn: The token owner can mint and burn tokens, increasing or decreasing the token supply.

- Transfer with Fees: Transfers between accounts include a fee, which is deducted from the transferred amount.

- Token Approvals: Users can approve specific addresses to spend their tokens on their behalf. Partial approvals are allowed.

- Blacklist Management: The contract owner can blacklist specific accounts to prevent them from conducting transactions.

- Time-Based Transactions: Certain transactions are time-dependent, allowing transfers to occur only after a specific time has passed.

## Getting Started

1. **Clone the Repository:** Clone this repository to your local machine.

2. **Compile Contracts:** Use a Solidity compiler compatible with Solidity 0.8.0 to compile the contracts.

3. **Deploy Contracts:** Deploy the contracts to your chosen Ethereum network using a tool like Remix, Truffle, or Hardhat.

4. **Interact with Contracts:** Use Ethereum wallet software or tools like Remix to interact with the deployed contracts. You can mint and burn tokens, transfer tokens, manage approvals, and more.

## Contract Upgrades

The `GodCoinV2` contract represents an upgraded version of the original contract with additional features or improvements. If you wish to upgrade the contract in the future, follow these steps:

1. Deploy a new instance of `GodCoinV2`.

2. Migrate data from the old contract to the new contract if necessary.

3. Update your application to interact with the new contract.

## License

This code is released under the MIT License. You can find the full text of the license in the `LICENSE` file.

---
