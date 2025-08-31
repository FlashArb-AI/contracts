// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title ImprovedFlashArbitrage V3
 * @author FlashArbAI
 * @notice Advanced decentralized arbitrage contract with multi-token flash loans, MEV protection, and dynamic pricing
 * @dev Implements sophisticated arbitrage strategies with comprehensive risk management and MEV resistance
 *
 * New V3 Features:
 * - Multi-token simultaneous flash loans for complex arbitrage strategies
 * - Chainlink price feed integration for profit validation
 * - Dynamic gas price adjustment and MEV protection
 * - Route optimization with multi-hop support
 * - Automated profit threshold adjustment based on market volatility
 * - Circuit breaker mechanism for risk management
 * - Multi-DEX router support with failover mechanisms
 * - Advanced slippage calculation using TWAP
 * - Profit sharing mechanism with configurable splits
 * - Cross-chain arbitrage preparation (bridge integration ready)
 *
 * @custom:security Enhanced MEV protection and circuit breaker mechanisms
 * @custom:optimization Advanced routing and gas optimization strategies
 */
contract ImprovedFlashArbitrageV3 is IFlashLoanRecipient, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    //////////////////////////////////////////////////////////////
    //                        CONSTANTS                        //
    //////////////////////////////////////////////////////////////

    /// @notice Balancer V2 Vault address for flash loans
    IVault private constant VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    /// @notice Maximum basis points (100%)
    uint256 private constant MAX_BPS = 10000;

    /// @notice Default slippage tolerance in basis points (1%)
    uint256 private constant DEFAULT_SLIPPAGE_BPS = 100;

    /// @notice Maximum allowed slippage in basis points (5%)
    uint256 private constant MAX_SLIPPAGE_BPS = 500;

    /// @notice Base minimum profit threshold in basis points (0.05%)
    uint256 private constant BASE_MIN_PROFIT_BPS = 5;

    /// @notice Maximum number of tokens in a single flash loan
    uint256 private constant MAX_FLASH_TOKENS = 5;

    /// @notice Maximum number of hops in a trading route
    uint256 private constant MAX_ROUTE_HOPS = 4;

    /// @notice Circuit breaker threshold (10% of total volume)
    uint256 private constant CIRCUIT_BREAKER_THRESHOLD_BPS = 1000;

    /// @notice MEV protection minimum delay in blocks
    uint256 private constant MEV_PROTECTION_BLOCKS = 2;

    //////////////////////////////////////////////////////////////
    //                        ENUMS                           //
    //////////////////////////////////////////////////////////////

    /// @notice Available DEX protocols for routing
    enum DexProtocol {
        UNISWAP_V3,
        SUSHISWAP,
        CURVE,
        BALANCER_V2,
        BANCOR_V3
    }

    /// @notice Circuit breaker states
    enum CircuitBreakerState {
        NORMAL,
        WARNING,
        EMERGENCY
    }

    //////////////////////////////////////////////////////////////
    //                        STRUCTS                         //
    //////////////////////////////////////////////////////////////

    /// @notice Multi-token flash loan parameters
    struct MultiFlashParams {
        address[] tokens;
        uint256[] amounts;
        bytes32 strategyId;
        uint256 deadline;
        uint256 maxGasPrice;
        bool mevProtection;
    }

    /// @notice Enhanced arbitrage route with multi-hop support
    struct ArbitrageRoute {
        DexProtocol[] protocols;
        address[] routers;
        address[] tokens;
        uint24[] fees;
        uint256[] minAmountsOut;
        bytes[] extraData; // For protocol-specific parameters
    }

    /// @notice Enhanced statistics with volatility tracking
    struct StatisticsV3 {
        uint256 totalTrades;
        uint256 totalProfit;
        uint256 totalVolume;
        uint256 lastTradeTimestamp;
        uint256 averageProfit;
        uint256 volatilityIndex;
        uint256 mevProtectedTrades;
        uint256 circuitBreakerTriggers;
    }

    /// @notice Price feed configuration
    struct PriceFeedConfig {
        AggregatorV3Interface priceFeed;
        uint256 heartbeat;
        uint256 deviation;
        bool isActive;
    }

    /// @notice Profit sharing configuration
    struct ProfitSharing {
        address recipient;
        uint256 basisPoints;
    }

    /// @notice Circuit breaker configuration
    struct CircuitBreaker {
        uint256 maxVolumePerPeriod;
        uint256 maxTradesPerPeriod;
        uint256 periodDuration;
        uint256 currentPeriodStart;
        uint256 currentVolume;
        uint256 currentTrades;
        CircuitBreakerState state;
    }

    //////////////////////////////////////////////////////////////
    //                        STATE VARIABLES                 //
    //////////////////////////////////////////////////////////////

    /// @notice Enhanced contract statistics
    StatisticsV3 public stats;

    /// @notice Mapping of authorized addresses
    mapping(address => bool) public authorizedCallers;

    /// @notice Price feed configurations by token
    mapping(address => PriceFeedConfig) public priceFeeds;

    /// @notice Supported DEX routers by protocol
    mapping(DexProtocol => address[]) public dexRouters;

    /// @notice Failed route tracking for optimization
    mapping(bytes32 => uint256) public failedRoutes;

    /// @notice Maximum gas price for execution
    uint256 public maxGasPrice = 100 gwei;

    //////////////////////////////////////////////////////////////
    //                        EVENTS                          //
    //////////////////////////////////////////////////////////////

    /// @notice Emitted when a multi-token arbitrage is executed
   event MultiTokenArbitrageExecuted(
        bytes32 indexed strategyId,
        address[] tokens,
        uint256[] amounts,
        uint256 totalProfit,
        uint256 gasUsed,
        bool mevProtected
    );

    /// @notice Emitted when circuit breaker state changes
    event CircuitBreakerStateChanged(
        CircuitBreakerState oldState,
        CircuitBreakerState newState,
        uint256 currentVolume,
        uint256 threshold
    );

    /// @notice Emitted when a route fails
    event RouteFailed(
        bytes32 indexed routeHash,
        DexProtocol protocol,
        string reason,
        uint256 timestamp
    );

    /// @notice Emitted when price feed is updated
    event PriceFeedUpdated(
        address indexed token,
        address indexed priceFeed,
        uint256 heartbeat
    );

    /// @notice Emitted when profit is shared
    event ProfitShared(
        address indexed recipient,
        uint256 amount,
        uint256 basisPoints
    );

    /// @notice Emitted when dynamic parameters are updated
    event DynamicParametersUpdated(
        uint256 newProfitMultiplier,
        uint256 volatilityIndex,
        uint256 timestamp
    );

    /// @notice Missing event from V2
    event EmergencyWithdrawal(
        address indexed token,
        uint256 amount,
        address indexed recipient
    );

    //////////////////////////////////////////////////////////////
    //                        MODIFIERS                       //
    //////////////////////////////////////////////////////////////

    /// @notice Enhanced authorization with MEV protection
    modifier onlyAuthorizedWithMEV(bool mevProtection) {
        require(authorizedCallers[msg.sender] || msg.sender == owner(), "Not authorized");
        
        if (mevProtection) {
            require(
                block.number > lastExecutionBlock[msg.sender] + MEV_PROTECTION_BLOCKS,
                "MEV protection active"
            );
            lastExecutionBlock[msg.sender] = block.number;
        }
        _;
    }

    /// @notice Circuit breaker validation
    modifier circuitBreakerCheck(uint256 volume) {
        _updateCircuitBreaker(volume);
        require(circuitBreaker.state != CircuitBreakerState.EMERGENCY, "Circuit breaker: Emergency stop");
        _;
    }

    /// @notice Gas price protection
    modifier gasProtection(uint256 maxGas) {
        require(tx.gasprice <= maxGas, "Gas price too high");
        _;
    }

    /// @notice Enhanced trade parameter validation
    modifier validTradeParamsV3(ArbitrageParamsV3 memory params) {
        require(params.flashParams.tokens.length > 0, "No flash tokens");
        require(params.flashParams.tokens.length <= MAX_FLASH_TOKENS, "Too many flash tokens");
        require(params.buyRoute.tokens.length <= MAX_ROUTE_HOPS + 1, "Buy route too long");
        require(params.sellRoute.tokens.length <= MAX_ROUTE_HOPS + 1, "Sell route too long");
        require(params.flashParams.deadline >= block.timestamp, "Trade deadline passed");
        require(params.maxExecutionTime > 0, "Invalid execution time");
        _;
    }

    //////////////////////////////////////////////////////////////
    //                        CONSTRUCTOR                     //
    //////////////////////////////////////////////////////////////

    constructor() {
        authorizedCallers[msg.sender] = true;
        
        // Initialize circuit breaker
        circuitBreaker = CircuitBreaker({
            maxVolumePerPeriod: 1000 ether,
            maxTradesPerPeriod: 100,
            periodDuration: 1 hours,
            currentPeriodStart: block.timestamp,
            currentVolume: 0,
            currentTrades: 0,
            state: CircuitBreakerState.NORMAL
        });

        emit CallerAuthorizationChanged(msg.sender, true);
    }

    //////////////////////////////////////////////////////////////
    //                        MAIN FUNCTIONS                  //
    //////////////////////////////////////////////////////////////

    /// @notice Execute multi-token arbitrage with enhanced features
    function executeAdvancedArbitrage(ArbitrageParamsV3 calldata params)
        external
        nonReentrant
        whenNotPaused
        onlyAuthorizedWithMEV(params.flashParams.mevProtection)
        validTradeParamsV3(params)
        circuitBreakerCheck(_calculateTotalVolume(params.flashParams.amounts))
        gasProtection(params.flashParams.maxGasPrice)
    {
        uint256 gasStart = gasleft();

        // Enhanced profitability check with price feeds
        uint256 estimatedProfit = _estimateProfitWithFeeds(params);
        uint256 dynamicMinProfit = _calculateDynamicMinProfit(
            _calculateTotalVolume(params.flashParams.amounts)
        );
        
        require(estimatedProfit >= dynamicMinProfit, "Insufficient dynamic profit");

        // Validate routes haven't failed recently
        _validateRoutes(params);

        // Execute multi-token flash loan
        bytes memory data = abi.encode(params);
        
        IERC20[] memory tokens = new IERC20[](params.flashParams.tokens.length);
        for (uint i = 0; i < params.flashParams.tokens.length; i++) {
            tokens[i] = IERC20(params.flashParams.tokens[i]);
        }

        VAULT.flashLoan(this, tokens, params.flashParams.amounts, data);

        uint256 gasUsed = gasStart - gasleft();
        
        // Update enhanced statistics
        _updateAdvancedStatistics(params, gasUsed);
    }

    /// @notice Enhanced flash loan callback with multi-token support
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(VAULT), "Only Vault can call");

        ArbitrageParamsV3 memory params = abi.decode(userData, (ArbitrageParamsV3));
        
        uint256 executionStart = block.timestamp;
        require(block.timestamp <= params.flashParams.deadline, "Execution deadline exceeded");

        // Track initial balances for all tokens
        uint256[] memory initialBalances = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            initialBalances[i] = tokens[i].balanceOf(address(this));
        }

        // Execute buy route
        uint256[] memory intermediateAmounts = _executeRouteV3(params.buyRoute, amounts);

        // Execute sell route
        uint256[] memory finalAmounts = _executeRouteV3(params.sellRoute, intermediateAmounts);

        // Validate execution time
        require(
            block.timestamp - executionStart <= params.maxExecutionTime,
            "Execution time exceeded"
        );

        // Repay flash loans and calculate profits
        uint256 totalProfit = 0;
        for (uint i = 0; i < tokens.length; i++) {
            tokens[i].safeTransfer(address(VAULT), amounts[i] + feeAmounts[i]);
            
            uint256 finalBalance = tokens[i].balanceOf(address(this));
            if (finalBalance > initialBalances[i]) {
                uint256 tokenProfit = finalBalance - initialBalances[i];
                totalProfit += tokenProfit;
                
                // Distribute profit according to sharing rules
                _distributeProfits(address(tokens[i]), tokenProfit);
            }
        }

        require(totalProfit >= params.expectedProfit, "Profit below expectation");

        emit MultiTokenArbitrageExecuted(
            params.flashParams.strategyId,
            params.flashParams.tokens,
            amounts,
            totalProfit,
            0,
            params.flashParams.mevProtection
        );
    }

    //////////////////////////////////////////////////////////////
    //                        ADMIN FUNCTIONS                 //
    //////////////////////////////////////////////////////////////

    /// @notice Configure price feed for a token
    function setPriceFeed(
        address token,
        address priceFeed,
        uint256 heartbeat,
        uint256 deviation
    ) external onlyOwner {
        priceFeeds[token] = PriceFeedConfig({
            priceFeed: AggregatorV3Interface(priceFeed),
            heartbeat: heartbeat,
            deviation: deviation,
            isActive: true
        });
        
        emit PriceFeedUpdated(token, priceFeed, heartbeat);
    }

    /// @notice Add DEX router for a protocol
    function addDexRouter(DexProtocol protocol, address router, address quoter) external onlyOwner {
        dexRouters[protocol].push(router);
        if (quoter != address(0)) {
            quoters[protocol] = quoter;
        }
    }

    /// @notice Configure profit sharing
    function setProfitSharing(ProfitSharing[] calldata newSharings) external onlyOwner {
        delete profitSharings;
        
        uint256 totalBps = 0;
        for (uint i = 0; i < newSharings.length; i++) {
            require(newSharings[i].recipient != address(0), "Invalid recipient");
            profitSharings.push(newSharings[i]);
            totalBps += newSharings[i].basisPoints;
        }
        
        require(totalBps <= MAX_BPS, "Total sharing exceeds 100%");
    }

    /// @notice Update circuit breaker parameters
    function updateCircuitBreaker(
        uint256 maxVolumePerPeriod,
        uint256 maxTradesPerPeriod,
        uint256 periodDuration
    ) external onlyOwner {
        circuitBreaker.maxVolumePerPeriod = maxVolumePerPeriod;
        circuitBreaker.maxTradesPerPeriod = maxTradesPerPeriod;
        circuitBreaker.periodDuration = periodDuration;
    }

    /// @notice Update dynamic profit multiplier based on market conditions
    function updateDynamicParameters() external onlyOwner {
        uint256 newVolatility = _calculateVolatilityIndex();
        uint256 newMultiplier = BASE_MIN_PROFIT_BPS + (newVolatility * 2);
        
        dynamicProfitMultiplier = newMultiplier > MAX_BPS ? MAX_BPS : newMultiplier;
        stats.volatilityIndex = newVolatility;
        
        emit DynamicParametersUpdated(dynamicProfitMultiplier, newVolatility, block.timestamp);
    }

    /// @notice Reset failed route tracking
    function resetFailedRoute(bytes32 routeHash) external onlyOwner {
        failedRoutes[routeHash] = 0;
    }

    /// @notice Emergency circuit breaker override
    function emergencyCircuitBreaker(CircuitBreakerState newState) external onlyOwner {
        CircuitBreakerState oldState = circuitBreaker.state;
        circuitBreaker.state = newState;
        
        emit CircuitBreakerStateChanged(oldState, newState, circuitBreaker.currentVolume, 0);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
