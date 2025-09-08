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

# Contract addresses
BALANCER_VAULT := 0xBA12222222228d8Ba445958a75a0704d566BF2C8
UNISWAP_V3_ROUTER := 0xE592427A0AEce92De3Edee1F18E0157C05861564
UNISWAP_V3_QUOTER := 0x61fFE014bA17989E743c5F6cB21bF9697530B21e

# Gas configurations
GAS_LIMIT := 5000000
GAS_PRICE := 20000000000
PRIORITY_GAS_PRICE := 2000000000
