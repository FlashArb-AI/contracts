# FlashArbAI Project

## Overview

FlashArbAI is a decentralized finance (DeFi) arbitrage bot that leverages Balancer V2 flash loans to identify and execute arbitrage opportunities across decentralized exchanges (DEXs). The project integrates with the Goat Framework and utilizes the Eliza AI agent plugin to provide a conversational interface for users. Users can interact with the AI agent to discover supported token pairs, monitor arbitrage opportunities, and execute trades when profitable opportunities arise.

The core of the project is the `Arbitrage` smart contract, which handles flash loans, token swaps, and profit calculations. The contract is deployed and supports DEXs that share the same interface as Uniswap V3.

## Features

- **Balancer V2 Flash Loans**: Borrow tokens without collateral to execute arbitrage trades.
- **Uniswap V3 Integration**: Swap tokens on Uniswap V3-compatible DEXs.
- **AI-Powered Interface**: Interact with the Eliza AI agent to discover and monitor arbitrage opportunities.
- **Customizable Token Pairs**: Users can select from a list of supported token pairs for arbitrage.
- **Profit Distribution**: Profits from arbitrage trades are transferred to the contract owner.

## Smart Contract Details

### Contract: `Arbitrage.sol`

The `Arbitrage` contract is the core of the FlashArbAI project. It implements the `IFlashLoanRecipient` interface to receive flash loans from Balancer V2 and executes arbitrage trades on Uniswap V3-compatible DEXs.

#### Key Functions

1. **`executeTrade`**:
   - Initiates a flash loan to execute an arbitrage trade.
   - Parameters:
     - `_routerPath`: Addresses of the swap routers for each trade.
     - `_quoterPath`: Addresses of the quoters for price calculations.
     - `_tokenPath`: Addresses of the tokens involved in the trade.
     - `_fee`: Pool fee for the swap.
     - `_flashAmount`: Amount of tokens to flash loan.

2. **`receiveFlashLoan`**:
   - Callback function invoked by Balancer V2 after providing the flash loan.
   - Executes the arbitrage trade by swapping tokens on the specified DEXs.
   - Repays the flash loan and transfers profits to the contract owner.

3. **`_swapOnV3`**:
   - Internal function to execute a token swap on a Uniswap V3-compatible DEX.
   - Parameters:
     - `_router`: Address of the swap router.
     - `_tokenIn`: Address of the input token.
     - `_amountIn`: Amount of input tokens to swap.
     - `_tokenOut`: Address of the output token.
     - `_amountOut`: Minimum amount of output tokens expected.
     - `_fee`: Pool fee for the swap.

## Setup Instructions

### Prerequisites

1. **Foundry**: Install Foundry for smart contract development and testing.
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/flash-arb-ai.git
   cd flash-arb-ai
   ```

2. Install dependencies:
    ```bash
    forge install
    ```

3. Compile the smart contract:
    ```bash
    forge build
    ```

4. Deploy the contract, here is an example for Sepolia Testnet:
    ```bash
    forge script script/DeployArbitrage.s.sol:DeployArbitrage <SEPOLIA_RPC_URL> --private-key <PRIVATE_KEY> --broadcast --verify --verifier blockscout --verifier-url https://sepolia.explorer.network/api/
    ```

### Configuration

1. Update the foundry.toml file with your network RPC URL.

## Usage
### Executing Trades Programmatically
1. Call the `executeTrade` function on the Arbitrage contract using Foundry:
    ```bash
    cast send <CONTRACT_ADDRESS> "executeTrade(address[],address[],address[],uint24,uint256)" \
    "[<ROUTER1>, <ROUTER2>]" "[<QUOTER1>, <QUOTER2>]" "[<TOKEN1>, <TOKEN2>]" <FEE> <FLASH_AMOUNT> \
    --rpc-url <SEPOLIA_RPC_URL> --private-key <PRIVATE_KEY>
    ```

2. Monitor the TokensSwapped event to track trade execution and profits:
    ```bash
    cast logs --from-block <START_BLOCK> --to-block <END_BLOCK> --address <CONTRACT_ADDRESS> \
    --topic "TokensSwapped(address,address,uint256,uint256)" --rpc-url <SEPOLIA_RPC_URL>
    ```

## Testing
Foundry is used for testing the Arbitrage contract. To run the tests:

1. Write your tests in the test directory.

2. Run the tests using:
    ```bash
    forge test
    ```

## Contributing
Contributions to the FlashArbAI project are welcome! Please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix.

3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgments
- Balancer Labs for the Balancer V2 flash loan functionality.
- Uniswap Labs for the Uniswap V3 integration.