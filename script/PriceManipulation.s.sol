// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

/**
 * @title PriceManipulation
 * @author FlashArb-AI
 * @notice This script demonstrates price manipulation through large swaps on PancakeSwap V3
 * @dev A Foundry script that simulates price impact by executing large token swaps
 *      Uses vm.startPrank to impersonate a whale account with sufficient token balance
 *      WARNING: This is for educational/testing purposes only - price manipulation is illegal in many jurisdictions
 * @custom:security This script is for testing and educational purposes only
 * @custom:warning Price manipulation can be illegal and unethical in real markets
 */
contract PriceManipulation is Script {
    //////////////////////////////////////////////////////////////
    //                        STATE VARIABLES                  //
    //////////////////////////////////////////////////////////////

    /// @notice Network configuration struct containing addresses and parameters
    /// @dev Loaded from HelperConfig to get network-specific contract addresses
    HelperConfig.ForkNetworkConfig public networkConfig;

    /// @notice Helper configuration contract instance
    /// @dev Used to retrieve network-specific configuration parameters
    HelperConfig public helperConfig;

    //////////////////////////////////////////////////////////////
    //                        CONSTANTS                        //
    //////////////////////////////////////////////////////////////

    /// @notice Pool fee tier for PancakeSwap V3 operations (0.05%)
    /// @dev 500 represents 0.05% fee tier in basis points
    uint24 constant POOL_FEE = 500;

    /// @notice Amount of tokens to swap for price manipulation
    /// @dev Large amount (1000 ETH) designed to create significant price impact
    /// @custom:warning This large amount is intentionally chosen to demonstrate price impact
    uint256 constant MANIPULATION_AMOUNT = 1000 ether;

    /// @notice Address of the whale account to impersonate
    /// @dev EOS address with substantial WETH balance for manipulation testing
    /// @custom:impersonation This address will be impersonated using vm.startPrank
    address constant UNLOCKED_ACCOUNT = 0xb2cc224c1c9feE385f8ad6a55b4d94E92359DC59;

    //////////////////////////////////////////////////////////////
    //                        FUNCTIONS                        //
    //////////////////////////////////////////////////////////////

    /**
     * @notice Initializes the script by setting up network configuration
     * @dev Creates HelperConfig instance and loads Sepolia ETH configuration
     *      Logs initial setup information for debugging purposes
     * @custom:setup Called automatically by Foundry before script execution
     */
    function setUp() public {
        console.log("Starting setup...");
        helperConfig = new HelperConfig();
        networkConfig = helperConfig.getSepoliaETHConfig();
        console.log("Setup complete. Config loaded.");
        console.log("WETH address:", networkConfig.weth);
        console.log("PancakeSwap Router:", networkConfig.pancakeSwapRouter);
    }

    function getPriceQuote(address tokenIn, address tokenOut) internal returns (uint256) {
        IQuoterV2 quoter = IQuoterV2(networkConfig.pancakeSwapQuoter);

        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: 1 ether, // Quote for 1 WETH
            fee: POOL_FEE,
            sqrtPriceLimitX96: 0
        });

        (uint256 amountOut,,,) = quoter.quoteExactInputSingle(params);
        return amountOut;
    }

    function run() public {
        console.log("Starting script execution...");

        console.log("Dealing ETH to whale...");
        // Only need ETH for gas
        vm.deal(UNLOCKED_ACCOUNT, 1 ether);

        // Log initial balances and price
        uint256 initialWethBalance = IERC20(networkConfig.weth).balanceOf(UNLOCKED_ACCOUNT);
        uint256 initialUsdcBalance = IERC20(networkConfig.usdc).balanceOf(UNLOCKED_ACCOUNT);
        uint256 initialPrice = getPriceQuote(networkConfig.weth, networkConfig.usdc);

        console.log("Initial WETH Balance:", initialWethBalance / 1e18, "WETH");
        console.log("Initial USDC Balance:", initialUsdcBalance / 1e6, "USDC");
        console.log("Initial WETH/USDC Price:", initialPrice / 1e6);

        // Impersonate account
        vm.startPrank(UNLOCKED_ACCOUNT);

        // Get token contract and approve
        IERC20(networkConfig.weth).approve(networkConfig.pancakeSwapRouter, MANIPULATION_AMOUNT);

        // Create a large swap to impact price
        ISwapRouter router = ISwapRouter(networkConfig.pancakeSwapRouter);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: networkConfig.weth,
            tokenOut: networkConfig.usdc,
            fee: POOL_FEE,
            recipient: UNLOCKED_ACCOUNT,
            deadline: block.timestamp + 20 minutes,
            amountIn: MANIPULATION_AMOUNT,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        router.exactInputSingle(params);

        // Log final balances and price
        uint256 finalWethBalance = IERC20(networkConfig.weth).balanceOf(UNLOCKED_ACCOUNT);
        uint256 finalUsdcBalance = IERC20(networkConfig.usdc).balanceOf(UNLOCKED_ACCOUNT);
        uint256 finalPrice = getPriceQuote(networkConfig.weth, networkConfig.usdc);

        console.log("\nFinal WETH Balance:", finalWethBalance / 1e18, "WETH");
        console.log("Final USDC Balance:", finalUsdcBalance / 1e6, "USDC");
        console.log("Final WETH/USDC Price:", finalPrice / 1e6);
        int256 priceImpact = ((int256(finalPrice) - int256(initialPrice)) * 100) / int256(initialPrice);
        console.log("Price Impact:");
        console.logInt(priceImpact);
        console.log("%");

        vm.stopPrank();
    }
}
