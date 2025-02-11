// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@balancer/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";
import "@balancer/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IFlashLoanRecipient.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

/**
 * @title FlashArbitrage
 * @author FlashArbAI
 * @notice Advanced DEX arbitrage executor leveraging Balancer flash loans
 * @dev Implements cross-DEX arbitrage strategies using flash loans and optimized swap paths
 */
contract FlashArbitrage is IFlashLoanRecipient {
    /// @notice Balancer V2 Vault for flash loan operations
    IVault private constant BALANCER_VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    address public strategist;

    /// @notice Defines parameters for a complete arbitrage operation
    struct ArbStrategy {
        address[] dexRouters; // Addresses of DEX routers to use
        address[] priceQuoters; // Price quoter contracts for each DEX
        address[] tradingPath; // Token addresses in trading sequence
        uint24 poolFee; // Trading fee tier (3000 = 0.3%)
    }

    event ArbitrageExecuted(address sourceToken, address targetToken, uint256 inputAmount, uint256 minimumReturn);

    constructor() {
        strategist = msg.sender;
    }

    /**
     * @notice Initiates an arbitrage operation with flash loan
     * @param _dexRouters Array of DEX router addresses for the arbitrage path
     * @param _priceQuoters Array of price quoter addresses for each DEX
     * @param _tradingPath Array of token addresses in the arbitrage sequence
     * @param _poolFee Fee tier for the pools to use
     * @param _loanSize Size of the flash loan to initiate
     */
    function executeArbitrage(
        address[] memory _dexRouters,
        address[] memory _priceQuoters,
        address[] memory _tradingPath,
        uint24 _poolFee,
        uint256 _loanSize
    ) external {
        bytes memory strategyData = abi.encode(
            ArbStrategy({
                dexRouters: _dexRouters,
                priceQuoters: _priceQuoters,
                tradingPath: _tradingPath,
                poolFee: _poolFee
            })
        );

        // Configure flash loan parameters
        IERC20[] memory loanTokens = new IERC20[](1);
        loanTokens[0] = IERC20(_tradingPath[0]);

        uint256[] memory loanAmounts = new uint256[](1);
        loanAmounts[0] = _loanSize;

        BALANCER_VAULT.flashLoan(this, loanTokens, loanAmounts, strategyData);
    }

    /**
     * @notice Handles the flash loan callback and executes the arbitrage strategy
     * @dev Implements the core arbitrage logic: borrow → swap A → swap B → repay
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(BALANCER_VAULT), "Unauthorized callback");

        ArbStrategy memory strategy = abi.decode(userData, (ArbStrategy));
        uint256 loanAmount = amounts[0];

        // Execute first leg of arbitrage
        executeSwap(
            strategy.dexRouters[0],
            strategy.tradingPath[0],
            loanAmount,
            strategy.tradingPath[1],
            0, // Accept any output for first swap
            strategy.poolFee
        );

        // Execute second leg of arbitrage
        uint256 intermediateBalance = IERC20(strategy.tradingPath[1]).balanceOf(address(this));
        executeSwap(
            strategy.dexRouters[1],
            strategy.tradingPath[1],
            intermediateBalance,
            strategy.tradingPath[0],
            loanAmount, // Minimum output must cover flash loan
            strategy.poolFee
        );

        // Repay flash loan
        IERC20(strategy.tradingPath[0]).transfer(address(BALANCER_VAULT), loanAmount);

        // Transfer profits to strategist
        uint256 profitAmount = IERC20(strategy.tradingPath[0]).balanceOf(address(this));
        if (profitAmount > 0) {
            IERC20(strategy.tradingPath[0]).transfer(strategist, profitAmount);
        }
    }

    /**
     * @notice Executes a single swap on a DEX
     * @dev Optimized for exact input swaps with minimum output requirements
     */
    function executeSwap(
        address _dexRouter,
        address _tokenIn,
        uint256 _swapAmount,
        address _tokenOut,
        uint256 _minReturn,
        uint24 _poolFee
    ) internal {
        IERC20(_tokenIn).approve(_dexRouter, _swapAmount);

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _swapAmount,
            amountOutMinimum: _minReturn,
            sqrtPriceLimitX96: 0
        });

        ISwapRouter(_dexRouter).exactInputSingle(swapParams);

        emit ArbitrageExecuted(_tokenIn, _tokenOut, _swapAmount, _minReturn);
    }
}
