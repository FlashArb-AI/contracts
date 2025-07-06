![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen)

# FlashArbAI Project

## Table of Contents

- [FlashArbAI Project](#flasharbai-project)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [System Architecture](#system-architecture)
  - [Workflow](#workflow)
  - [Smart Contract Details](#smart-contract-details)
    - [Contract: `Arbitrage.sol`](#contract-arbitragesol)
      - [Key Functions](#key-functions)
    - [Events](#events)
  - [Setup Instructions](#setup-instructions)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Environment Variables](#environment-variables)
    - [Configuration](#configuration)
  - [Usage](#usage)
    - [Executing Trades Programmatically](#executing-trades-programmatically)
    - [Using the AI Agent Interface](#using-the-ai-agent-interface)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Security Considerations](#security-considerations)
    - [Known Risks](#known-risks)
    - [Security Measures](#security-measures)
  - [Performance Optimization](#performance-optimization)
    - [Gas Optimization](#gas-optimization)
  - [Monitoring \& Analytics](#monitoring--analytics)
    - [Track key metrics:](#track-key-metrics)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
  - [API Reference](#api-reference)
    - [Contract Methods](#contract-methods)
    - [Parameters:](#parameters)
    - [Returns: Transaction hash](#returns-transaction-hash)
    - [Parameters:](#parameters-1)
  - [Roadmap](#roadmap)
    - [Phase 1 (Current)](#phase-1-current)
    - [Phase 2 (Planned)](#phase-2-planned)
    - [Phase 3 (Planned)](#phase-3-planned)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)
  - [Known Issues](#known-issues)
  - [Common questions:](#common-questions)
  - [Disclaimer](#disclaimer)


## Overview

FlashArbAI is a decentralized finance (DeFi) arbitrage bot that leverages Balancer V2 flash loans to identify and execute arbitrage opportunities across decentralized exchanges (DEXs). The project integrates with the Goat Framework and utilizes the Eliza AI agent plugin to provide a conversational interface for users. Users can interact with the AI agent to discover supported token pairs, monitor arbitrage opportunities, and execute trades when profitable opportunities arise.

The core of the project is the `Arbitrage` smart contract, which handles flash loans, token swaps, and profit calculations. The contract is deployed and supports DEXs that share the same interface as Uniswap V3 (aka Uniswap V3 Forks).

## Features

- **Balancer V2 Flash Loans**: Borrow tokens without collateral to execute arbitrage trades.
- **Uniswap V3 Integration**: Swap tokens on Uniswap V3-compatible DEXs.
- **AI-Powered Interface**: Interact with the Eliza AI agent to discover and monitor arbitrage opportunities.
- **Customizable Token Pairs**: Users can select from a list of supported token pairs for arbitrage.
- **Profit Distribution**: Profits from arbitrage trades are transferred to the contract owner.

## System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Eliza AI      │────│  FlashArbAI     │────│   Balancer V2   │
│   Agent         │    │  Arbitrage      │    │   Flash Loans   │
│                 │    │  Contract       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    User         │    │   Uniswap V3    │    │   Other DEXs    │
│  Interface      │    │   Compatible    │    │   (SushiSwap,   │
│                 │    │     DEXs        │    │   PancakeSwap)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```



## Workflow

1. **Opportunity Detection:** AI agent monitors price differences across supported DEXs
2. **Flash Loan Initiation:** Contract requests flash loan from Balancer V2
3. **Arbitrage Execution:** Execute swaps across different DEXs to capture price differences
4. **Profit Calculation:** Calculate net profit after fees and gas costs
5. **Loan Repayment:** Repay flash loan and transfer profits to contract owner

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

### Events
```solidity
event TokensSwapped(
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 amountIn,
    uint256 amountOut
);

event ArbitrageExecuted(
    address indexed tokenA,
    address indexed tokenB,
    uint256 profit,
    uint256 gasUsed
);
```

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

4. Deploy the contract, here is an example for Any Testnet:
    ```bash
    forge script script/DeployArbitrage.s.sol:DeployArbitrage <ANYTESTNET_RPC_URL> --private-key <PRIVATE_KEY> --broadcast --verify --verifier blockscout --verifier-url $VERIFIER_URL
    ```

### Environment Variables
Create `.env` file in the root directory:

```bash
# Network Configuration
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID

# Private Keys
PRIVATE_KEY=your_private_key_here

# Contract Addresses
BALANCER_VAULT=0xBA12222222228d8Ba445958a75a0704d566BF2C8
UNISWAP_V3_ROUTER=0xE592427A0AEce92De3Edee1F18E0157C05861564

# API Keys
ETHERSCAN_API_KEY=your_etherscan_api_key
COINGECKO_API_KEY=your_coingecko_api_key
```

### Configuration

1. Update the foundry.toml file with your network RPC URL.
2. Configure supported token pairs in `config/tokens.json`:
```json
{
  "supportedPairs": [
    {
      "tokenA": "0xA0b86a33E6441a1e60b5C5B5B5B1b5B5B5B5B5B5",
      "tokenB": "0xB0b86a33E6441a1e60b5C5B5B5B1b5B5B5B5B5B5",
      "name": "WETH/USDC",
      "minProfitThreshold": "0.01"
    }
  ]
}
```

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

### Using the AI Agent Interface
1. Start the Eliza AI agent:
```bash
pnpm run start:agent
```

2. Interact with the agent using natural language:
   - "Show me profitable arbitrage opportunities"
   - "Execute arbitrage for WETH/USDC pair"
   - "What's the current profit potential for ETH/DAI?"

## Testing
Foundry is used for testing the Arbitrage contract. To run the tests:

1. Write your tests in the test directory.

2. Run the tests using:
    ```bash
    forge test
    ```

### Test Coverage
Generage test coverage reports:
```bash
forge coverage
```

## Security Considerations
### Known Risks

- **MEV (Maximal Extractable Value):** Arbitrage transactions may be front-run by MEV bots
- **Flash Loan Attacks:** Ensure proper validation of flash loan repayment
- **Slippage:** Market conditions can change between opportunity detection and execution
- **Smart Contract Risk:** Potential bugs in contract logic or external dependencies

### Security Measures

- Reentrancy guards on critical functions
- Slippage protection with configurable thresholds
- Access control for sensitive operations
- Regular security audits (planned)

## Performance Optimization
### Gas Optimization
- Use of assembly for critical calculations
- Batch operations where possible
- Optimized storage patterns
- Efficient event emission

## Monitoring & Analytics
### Track key metrics:

- Arbitrage success rate
- Average profit per trade
- Gas costs vs. profits
- Network congestion impact

## Troubleshooting
### Common Issues
**Issue:** Flash loan execution fails
  - **Solution:** Check token balances and ensure sufficient liquidity

**Issue:** High gas costs eating into profits
  - **Solution:** Adjust minimum profit thresholds and monitor network conditions

**Issue:** Slippage too high
  - **Solution:** Increase slippage tolerance or reduce trade size

## API Reference
### Contract Methods
`executeTrade`

Executes an arbitrage trade using flash loans.

### Parameters:

- `_routerPath`(address[]): Array of router addresses
- `_quoterPath`(address[]): Array of quoter addresses
- `_tokenPath`(address[]): Array of token addresses
- `_fee (uint24)`: Pool fee
- `_flashAmount`(uint256): Flash loan amount

### Returns: Transaction hash
`getProfit`

Calculates potential profit for a given arbitrage opportunity.

### Parameters:

- `tokenA (address)`: First token address
- `tokenB (address)`: Second token address
- `amount (uint256)`: Trade amount

**Returns:** Estimated profit (uint256)

## Roadmap
### Phase 1 (Current)

✅ Core arbitrage contract development
✅ Balancer V2 flash loan integration
✅ Uniswap V3 compatibility
🚧 AI agent integration

### Phase 2 (Planned)

🔄 Multi-DEX support expansion
🔄 Advanced profit optimization algorithms
🔄 Web dashboard for monitoring
🔄 Mobile app development

### Phase 3 (Planned)

🔄 Cross-chain arbitrage
🔄 Institutional-grade API
🔄 Automated portfolio management
🔄 Third-party integrations

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

## Known Issues

- Only works with Uniswap V3 forks (for now)
- Needs more slippage protection
- Might fail if liquidity is too low

## Common questions:

- What tokens are supported?
- Which networks?
- How much gas does it usually cost?
- How do I add a new DEX?


## Disclaimer
This software is provided "as is" without warranty. Users are responsible for understanding the risks associated with DeFi trading and flash loans. Always test thoroughly on testnets before using with real funds.

⚠️ Warning: Flash loan arbitrage involves significant financial risk. Only use funds you can afford to lose and ensure you understand the technology before deployment.