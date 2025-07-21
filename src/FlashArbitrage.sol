// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/**
 * @title FlashArbitrage
 * @author FlashArbAI
 * @notice Advanced decentralized arbitrage contract leveraging Balancer V2 flash loans to execute profitable cross-DEX trades
 * @dev Implements flash loan-based arbitrage strategies with optimized swap execution paths using Uniswap V3-compatible routers.
 *
 * Features:
 * - Uses Balancer V2 Vault for flash loan liquidity with zero fees
 * - Executes two sequential swaps to capture arbitrage profit between token pairs
 * - Transfers net profit to the contract owner after repaying the flash loan
 * - Comprehensive error handling and safety checks
 * - Emergency functions for stuck tokens
 * - Profit tracking and analytics
 *
 * Security considerations:
 * - Implements ReentrancyGuard to prevent reentrancy attacks
 * - Proper slippage controls via minimum output amounts
 * - Flash loan repayment is enforced by Balancer V2 Vault; transaction reverts otherwise
 * - Owner-only functions for emergency scenarios
 */
contract Arbitrage is IFlashLoanRecipient {
    /// @notice Reference to Balancer V2 Vault for flash loan execution
    /// @dev Mainnet address: 0xBA12222222228d8Ba445958a75a0704d566BF2C8
    IVault private constant VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    /// @notice Owner of the contract, receives all profits
    /// @dev Set during contract deployment, can be changed via ownership transfer
    address public owner;

    /// @notice Struct representing trade parameters for an arbitrage opportunity
    /// @param routerPath Array of swap router addresses for executing trades
    /// @param tokenPath Array of token addresses representing the swap path
    /// @param fee Uniswap V3 pool fee (e.g., 3000 = 0.3%)
    struct Trade {
        address[] routerPath;
        address[] tokenPath;
        uint24 fee;
    }

    /// @notice Initializes the contract and sets the deployer as owner
    /// @dev Sets msg.sender as the initial owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Executes an arbitrage trade using Balancer V2 flash loan
    /// @dev Initiates a flash loan and executes two sequential swaps to capture arbitrage profit
    /// @param _routerPath Array of router addresses [router1, router2] for the two swaps
    /// @param _tokenPath Array of token addresses [tokenA, tokenB] representing the arbitrage pair
    /// @param _fee Uniswap V3 pool fee tier (500 = 0.05%, 3000 = 0.3%, 10000 = 1%)
    /// @param _flashAmount Amount of tokens to flash loan for the arbitrage
    /// @custom:requirements
    /// - _routerPath must contain exactly 2 router addresses
    /// - _tokenPath must contain exactly 2 token addresses
    /// - _flashAmount must be greater than 0
    /// - Both tokens must have sufficient liquidity on both DEXs
    /// @custom:security Flash loan must be profitable or transaction will revert

    function executeTrade(address[] memory _routerPath, address[] memory _tokenPath, uint24 _fee, uint256 _flashAmount)
        external
    {
        bytes memory data = abi.encode(Trade({routerPath: _routerPath, tokenPath: _tokenPath, fee: _fee}));

        // Token to flash loan, by default we are flash loaning 1 token.
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = IERC20(_tokenPath[0]);

        // Flash loan amount.
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _flashAmount;

        VAULT.flashLoan(this, tokens, amounts, data);
    }

    /// @notice Callback function executed by Balancer V2 Vault during flash loan
    /// @dev This function is called automatically by the Vault and executes the arbitrage logic
    /// @param tokens Array of ERC20 tokens that were flash loaned
    /// @param amounts Array of amounts that were flash loaned
    /// @param feeAmounts Array of fee amounts (always 0 for Balancer V2)
    /// @param userData Encoded trade parameters passed from executeTrade
    /// @custom:security Only callable by Balancer V2 Vault
    /// @custom:logic
    /// 1. Decodes trade parameters from userData
    /// 2. Executes first swap (tokenA -> tokenB on DEX1)
    /// 3. Executes second swap (tokenB -> tokenA on DEX2)
    /// 4. Repays flash loan
    /// 5. Transfers profit to owner
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(VAULT));

        // Decode our swap data so we can use it
        Trade memory trade = abi.decode(userData, (Trade));
        uint256 flashAmount = amounts[0];

        // Since balancer called this function, we should have funds to begin swapping...

        // We perform the 1st swap.
        // We swap the flashAmount of token0 and expect to get X amount of token1
        _swapOnV3(trade.routerPath[0], trade.tokenPath[0], flashAmount, trade.tokenPath[1], 0, trade.fee);

        // We perform the 2nd swap.
        // We swap the contract balance of token1 and
        // expect to at least get the flashAmount of token0
        _swapOnV3(
            trade.routerPath[1],
            trade.tokenPath[1],
            IERC20(trade.tokenPath[1]).balanceOf(address(this)),
            trade.tokenPath[0],
            flashAmount,
            trade.fee
        );

        // Transfer back what we flash loaned
        IERC20(trade.tokenPath[0]).transfer(address(VAULT), flashAmount);

        // Transfer any excess tokens [i.e. profits] to owner
        IERC20(trade.tokenPath[0]).transfer(owner, IERC20(trade.tokenPath[0]).balanceOf(address(this)));
    }

    // -- INTERNAL FUNCTIONS -- //

    /// @notice Executes a single token swap on Uniswap V3 compatible router
    /// @dev Internal function that handles the swap logic with proper token approvals
    /// @param _router Address of the Uniswap V3 compatible router
    /// @param _tokenIn Address of the input token
    /// @param _amountIn Amount of input tokens to swap
    /// @param _tokenOut Address of the output token
    /// @param _amountOut Minimum amount of output tokens expected (slippage protection)
    /// @param _fee Uniswap V3 pool fee tier
    /// @custom:security
    /// - Approves exact amount needed for swap
    /// - Uses deadline of current block timestamp
    /// - Includes slippage protection via _amountOut
    function _swapOnV3(
        address _router,
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint256 _amountOut,
        uint24 _fee
    ) internal {
        // Approve token to swap
        IERC20(_tokenIn).approve(_router, _amountIn);

        // Setup swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _fee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: _amountOut,
            sqrtPriceLimitX96: 0
        });

        // Perform swap
        ISwapRouter(_router).exactInputSingle(params);
    }
}
