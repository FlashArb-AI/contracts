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

build: ## Compile all contracts
	@echo "$(BLUE)🔨 Building contracts...$(RESET)"
	forge build
	@echo "$(GREEN)✅ Build completed successfully$(RESET)"

rebuild: clean build ## Clean rebuild of all contracts

build-optimized: ## Build with gas optimizations enabled
	@echo "$(BLUE)⚡ Building with optimizations...$(RESET)"
	forge build --optimize --optimize-runs 1000000
	@echo "$(GREEN)✅ Optimized build completed$(RESET)"

build-sizes: ## Show contract sizes after build
	@echo "$(BLUE)📊 Contract sizes:$(RESET)"
	forge build --sizes

# ================================================================
# TESTING SUITE
# ================================================================

test: ## Run all tests
	@echo "$(BLUE)🧪 Running tests...$(RESET)"
	forge test -vv

test-gas: ## Run tests with gas reporting
	@echo "$(BLUE)⛽ Running tests with gas reports...$(RESET)"
	forge test --gas-report

test-coverage: ## Generate test coverage report
	@echo "$(BLUE)📊 Generating coverage report...$(RESET)"
	mkdir -p $(COVERAGE_DIR)
	forge coverage --report lcov --report-file $(COVERAGE_DIR)/coverage.lcov
	genhtml $(COVERAGE_DIR)/coverage.lcov -o $(COVERAGE_DIR)/html
	@echo "$(GREEN)✅ Coverage report generated at $(COVERAGE_DIR)/html/index.html$(RESET)"

test-unit: ## Run unit tests only
	@echo "$(BLUE)🔬 Running unit tests...$(RESET)"
	forge test --match-path "test/unit/*" -vv

test-integration: ## Run integration tests only
	@echo "$(BLUE)🔗 Running integration tests...$(RESET)"
	forge test --match-path "test/integration/*" -vv

test-fork: ## Run fork tests against mainnet
	@echo "$(BLUE)🍴 Running fork tests...$(RESET)"
	forge test --fork-url $(MAINNET_RPC_URL) --match-path "test/fork/*" -vv

test-specific: ## Run specific test (usage: make test-specific TEST=TestName)
	@echo "$(BLUE)🎯 Running specific test: $(TEST)$(RESET)"
	forge test --match-test $(TEST) -vvvv

test-watch: ## Watch files and run tests on changes
	@echo "$(BLUE)👀 Watching for changes...$(RESET)"
	forge test --watch

# ================================================================
# CODE QUALITY & ANALYSIS
# ================================================================

fmt: ## Format code using forge fmt
	@echo "$(BLUE)💅 Formatting code...$(RESET)"
	forge fmt

fmt-check: ## Check code formatting
	@echo "$(BLUE)🔍 Checking code formatting...$(RESET)"
	forge fmt --check

lint: ## Run solhint linter
	@echo "$(BLUE)🔍 Running linter...$(RESET)"
	npx solhint 'src/**/*.sol' 'test/**/*.sol' 'script/**/*.sol'

analyze: ## Run slither static analysis
	@echo "$(BLUE)🔬 Running static analysis...$(RESET)"
	slither src/

mythril: ## Run mythril security analysis
	@echo "$(BLUE)🛡️ Running security analysis...$(RESET)"
	myth analyze src/ImprovedFlashArbitrageV3.sol

audit-prep: fmt build analyze ## Prepare for security audit

# ================================================================
# DEPLOYMENT SCRIPTS
# ================================================================

# Local deployment
deploy-local: ## Deploy to local anvil network
	@echo "$(BLUE)🚀 Deploying to local network...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast

# Testnet deployments
deploy-sepolia: ## Deploy to Sepolia testnet
	@echo "$(BLUE)🚀 Deploying to Sepolia...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--gas-limit $(GAS_LIMIT) \
		--gas-price $(GAS_PRICE)

deploy-goerli: ## Deploy to Goerli testnet
	@echo "$(BLUE)🚀 Deploying to Goerli...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(GOERLI_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)

# Mainnet deployments
deploy-mainnet: ## Deploy to Ethereum mainnet (requires confirmation)
	@echo "$(RED)⚠️  MAINNET DEPLOYMENT - Are you sure? (y/N)$(RESET)" && read ans && [ $${ans:-N} = y ]
	@echo "$(BLUE)🚀 Deploying to Ethereum mainnet...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(MAINNET_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--gas-limit $(GAS_LIMIT) \
		--priority-gas-price $(PRIORITY_GAS_PRICE)

deploy-polygon: ## Deploy to Polygon mainnet
	@echo "$(RED)⚠️  POLYGON DEPLOYMENT - Are you sure? (y/N)$(RESET)" && read ans && [ $${ans:-N} = y ]
	@echo "$(BLUE)🚀 Deploying to Polygon...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(POLYGON_RPC_URL) \
		--broadcast \
		--verify \
		--verifier-url https://api.polygonscan.com/api \
		--etherscan-api-key $(POLYGONSCAN_API_KEY)

deploy-arbitrum: ## Deploy to Arbitrum One
	@echo "$(RED)⚠️  ARBITRUM DEPLOYMENT - Are you sure? (y/N)$(RESET)" && read ans && [ $${ans:-N} = y ]
	@echo "$(BLUE)🚀 Deploying to Arbitrum...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(ARBITRUM_RPC_URL) \
		--broadcast \
		--verify \
		--verifier-url https://api.arbiscan.io/api \
		--etherscan-api-key $(ARBISCAN_API_KEY)

deploy-optimism: ## Deploy to Optimism
	@echo "$(RED)⚠️  OPTIMISM DEPLOYMENT - Are you sure? (y/N)$(RESET)" && read ans && [ $${ans:-N} = y ]
	@echo "$(BLUE)🚀 Deploying to Optimism...$(RESET)"
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url $(OPTIMISM_RPC_URL) \
		--broadcast

# ================================================================
# VERIFICATION & INTERACTION
# ================================================================

verify-mainnet: ## Verify contract on Etherscan
	@echo "$(BLUE)✅ Verifying contract on Etherscan...$(RESET)"
	forge verify-contract $(CONTRACT_ADDRESS) src/ImprovedFlashArbitrageV3.sol:ImprovedFlashArbitrageV3 \
		--chain-id 1 \
		--etherscan-api-key $(ETHERSCAN_API_KEY)

# Contract interaction scripts
interact-local: ## Run interaction script on local network
	@echo "$(BLUE)🔄 Running interaction script locally...$(RESET)"
	forge script script/Interact.s.sol:InteractionScript --rpc-url http://localhost:8545

interact-testnet: ## Run interaction script on testnet
	@echo "$(BLUE)🔄 Running interaction script on testnet...$(RESET)"
	forge script script/Interact.s.sol:InteractionScript --rpc-url $(SEPOLIA_RPC_URL)

# ================================================================
# LOCAL DEVELOPMENT
# ================================================================

anvil: ## Start local Anvil node
	@echo "$(BLUE)⚒️  Starting Anvil local node...$(RESET)"
	anvil --host 0.0.0.0 --port 8545 --chain-id 31337

anvil-fork: ## Start Anvil forked from mainnet
	@echo "$(BLUE)🍴 Starting Anvil forked from mainnet...$(RESET)"
	anvil --fork-url $(MAINNET_RPC_URL) --host 0.0.0.0 --port 8545

anvil-polygon: ## Start Anvil forked from Polygon
	@echo "$(BLUE)🍴 Starting Anvil forked from Polygon...$(RESET)"
	anvil --fork-url $(POLYGON_RPC_URL) --host 0.0.0.0 --port 8545

# ================================================================
# DOCUMENTATION
# ================================================================

docs: ## Generate documentation
	@echo "$(BLUE)📚 Generating documentation...$(RESET)"
	mkdir -p $(DOCS_DIR)
	forge doc --build --out $(DOCS_DIR)
	@echo "$(GREEN)✅ Documentation generated at $(DOCS_DIR)$(RESET)"

docs-serve: docs ## Serve documentation locally
	@echo "$(BLUE)🌐 Serving documentation at http://localhost:3000$(RESET)"
	forge doc --serve --port 3000