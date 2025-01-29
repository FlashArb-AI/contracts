// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

contract PriceManipulationTest is Test {
    // Configuration
    HelperConfig.ForkNetworkConfig public networkConfig;
    HelperConfig public helperConfig;

    // Constants
    uint24 constant PANCAKE_FEE = 100; // 0.05% for PancakeSwap
    uint24 constant UNISWAP_FEE = 500; // 0.05% for Uniswap
    uint256 constant MANIPULATION_AMOUNT = 1 ether; // Large swap to create price impact
    uint256 constant USDC_AMOUNT = 1 * 1e6; // 1000 USDC for testing
    address constant UNLOCKED_ACCOUNT = 0x0172e05392aba65366C4dbBb70D958BbF43304E4; // EOS address

    function setUp() public {
        console.log("Starting setup...");
        helperConfig = new HelperConfig();
        networkConfig = helperConfig.getSepoliaETHConfig();

        // Verify fork creation
        string memory rpcUrl = vm.envString("BASE_RPC_URL");
        vm.createSelectFork(rpcUrl, 25699770);
        console.log("Fork created");

        // Verify network config
        console.log("WETH address:", networkConfig.weth);
        console.log("USDC address:", networkConfig.usdc);
        console.log("PancakeSwap Router:", networkConfig.pancakeSwapRouter);
        console.log("Uniswap Router:", networkConfig.uniswapRouter);
    }

    // ========================
    // UniSwap Tests
    // ========================
    // function testUniswapWethToUsdc() public {
    //     vm.startPrank(UNLOCKED_ACCOUNT);

    //     // 1. Check WETH balance
    //     uint256 wethBalance = IERC20(networkConfig.weth).balanceOf(UNLOCKED_ACCOUNT);
    //     require(wethBalance >= 1 ether, "Insufficient WETH balance");

    //     // 2. Approve WETH
    //     IERC20(networkConfig.weth).approve(networkConfig.uniswapRouter, 1 ether);

    //     // 3. Get quote to validate output
    //     (uint256 quotedAmount,,,) = IQuoterV2(networkConfig.uniswapQuoter).quoteExactInputSingle(
    //         IQuoterV2.QuoteExactInputSingleParams({
    //             tokenIn: networkConfig.weth,
    //             tokenOut: networkConfig.usdc,
    //             amountIn: 1 ether,
    //             fee: 500,
    //             sqrtPriceLimitX96: 0
    //         })
    //     );
    //     require(quotedAmount > 0, "Invalid quote");

    //     // 4. Execute swap
    //     ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
    //         tokenIn: networkConfig.weth,
    //         tokenOut: networkConfig.usdc,
    //         fee: 500,
    //         recipient: UNLOCKED_ACCOUNT,
    //         deadline: block.timestamp + 20 minutes,
    //         amountIn: 1 ether,
    //         amountOutMinimum: 1, // Allow any output
    //         sqrtPriceLimitX96: 0
    //     });

    //     uint256 amountOut = ISwapRouter(networkConfig.uniswapRouter).exactInputSingle(params);
    //     console.log("USDC Received:", amountOut);
    //     vm.stopPrank();
    // }

    // // ========================
    // // PancakeSwap Tests
    // // ========================
    // function testPancakeSwapUsdcToWeth() public {
    //     vm.startPrank(UNLOCKED_ACCOUNT);

    //     uint256 initialUsdc = IERC20(networkConfig.usdc).balanceOf(UNLOCKED_ACCOUNT);
    //     uint256 initialWeth = IERC20(networkConfig.weth).balanceOf(UNLOCKED_ACCOUNT);

    //     // 1. Approve USDC
    //     IERC20(networkConfig.usdc).approve(networkConfig.pancakeSwapRouter, USDC_AMOUNT);

    //     // 2. Execute Swap
    //     ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
    //         tokenIn: networkConfig.usdc,
    //         tokenOut: networkConfig.weth,
    //         fee: PANCAKE_FEE,
    //         recipient: UNLOCKED_ACCOUNT,
    //         deadline: block.timestamp + 20 minutes,
    //         amountIn: USDC_AMOUNT,
    //         amountOutMinimum: 1, // ✅ Match Hardhat script
    //         sqrtPriceLimitX96: 0
    //     });

    //     // 3. Perform swap
    //     uint256 amountOut = ISwapRouter(networkConfig.pancakeSwapRouter).exactInputSingle(params);

    //     // 4. Verify balances
    //     assertLt(IERC20(networkConfig.usdc).balanceOf(UNLOCKED_ACCOUNT), initialUsdc);
    //     assertGt(IERC20(networkConfig.weth).balanceOf(UNLOCKED_ACCOUNT), initialWeth);
    //     vm.stopPrank();
    // }

    function test_receiveFlashLoan() public {}
}
