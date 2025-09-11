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

# Verification services
ETHERSCAN_API_KEY := $(ETHERSCAN_API_KEY)
POLYGONSCAN_API_KEY := $(POLYGONSCAN_API_KEY)
ARBISCAN_API_KEY := $(ARBISCAN_API_KEY)

# Build directories
BUILD_DIR := out
CACHE_DIR := cache
ARTIFACTS_DIR := artifacts
DOCS_DIR := docs
COVERAGE_DIR := coverage
REPORTS_DIR := reports

# Colors for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
WHITE := \033[37m
RESET := \033[0m

# ================================================================
# DEFAULT TARGET
# ================================================================

.DEFAULT_GOAL := help
.PHONY: help

help: ## Display this help message
	@echo "$(CYAN)===============================================$(RESET)"
	@echo "$(CYAN)  Flash Arbitrage V3 - Development Makefile  $(RESET)"
	@echo "$(CYAN)===============================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)📋 Available Commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)🔧 Configuration:$(RESET)"
	@echo "  Project: $(MAGENTA)$(PROJECT_NAME)$(RESET) v$(MAGENTA)$(VERSION)$(RESET)"
	@echo "  Solidity: $(MAGENTA)$(SOLIDITY_VERSION)$(RESET)"
	@echo "  Profile: $(MAGENTA)$(FOUNDRY_PROFILE)$(RESET)"
	@echo ""

# ================================================================
# DEVELOPMENT ENVIRONMENT
# ================================================================

install: ## Install dependencies and initialize project
	@echo "$(BLUE)🔧 Installing Foundry dependencies...$(RESET)"
	forge install foundry-rs/forge-std
	forge install OpenZeppelin/openzeppelin-contracts
	forge install balancer-labs/v2-interfaces
	forge install Uniswap/v3-periphery
	forge install smartcontractkit/chainlink
	@echo "$(GREEN)✅ Dependencies installed successfully$(RESET)"

update: ## Update all dependencies to latest versions
	@echo "$(BLUE)🔄 Updating dependencies...$(RESET)"
	forge update
	@echo "$(GREEN)✅ Dependencies updated$(RESET)"

clean: ## Clean build artifacts and cache
	@echo "$(BLUE)🧹 Cleaning build artifacts...$(RESET)"
	forge clean
	rm -rf $(BUILD_DIR) $(CACHE_DIR) $(ARTIFACTS_DIR) $(COVERAGE_DIR) $(REPORTS_DIR)
	@echo "$(GREEN)✅ Project cleaned$(RESET)"

reset: clean install ## Reset project (clean + reinstall)
	@echo "$(GREEN)✅ Project reset complete$(RESET)"

# ================================================================
# BUILD SYSTEM
# ================================================================
