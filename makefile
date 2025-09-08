# Flash Arbitrage V3 - Comprehensive Makefile
# Author: FlashArbAI
# Description: Complete build, test, and deployment automation for Foundry-based Solidity project

# ================================================================
# PROJECT CONFIGURATION
# ================================================================

# Project metadata
PROJECT_NAME := flash-arbitrage-v3
VERSION := 3.0.0
AUTHOR := FlashArbAI

# Foundry configuration
FOUNDRY_PROFILE := default
SOLIDITY_VERSION := 0.8.18

# Network configurations
MAINNET_RPC_URL := https://eth-mainnet.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
POLYGON_RPC_URL := https://polygon-mainnet.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
ARBITRUM_RPC_URL := https://arb-mainnet.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
OPTIMISM_RPC_URL := https://opt-mainnet.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
SEPOLIA_RPC_URL := https://eth-sepolia.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
GOERLI_RPC_URL := https://eth-goerli.alchemyapi.io/v2/$(ALCHEMY_API_KEY)
