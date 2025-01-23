// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {Arbitrage} from "../../src/Arbitrage.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract ArbitrageTest is Test {
    Arbitrage public arbitrage;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig currentConfig;
    address owner = address(1);
    uint256 sepoliaFork;
    uint256 baseSepoliaFork;

    string ETH_SEPOLIA_RPC_URL = vm.envString("ETH_SEPOLIA_RPC_URL");
    string BASE_SEPOLIA_RPC_URL = vm.envString("BASE_SEPOLIA_RPC_URL");

    function setUp() public {
        helperConfig = new HelperConfig();
        currentConfig = helperConfig.getBaseSepoliaConfig();
        vm.startPrank(owner);
        // sepoliaFork = vm.createSelectFork(ETH_SEPOLIA_RPC_URL);
        baseSepoliaFork = vm.createFork(BASE_SEPOLIA_RPC_URL);
        vm.selectFork(baseSepoliaFork);
        arbitrage = new Arbitrage(currentConfig.uniswapQuoter);
        vm.stopPrank();
        deal(currentConfig.usdc, owner, 69);
        deal(currentConfig.usdc, address(arbitrage), 69);
        vm.deal(owner, 1 ether);
    }

    function test_swapOnV3_uniswap() public {
        console.log(IERC20(currentConfig.usdc).balanceOf(owner));
        console.log(IERC20(currentConfig.usdc).balanceOf(address(arbitrage)));
        vm.selectFork(baseSepoliaFork);
        uint256 fee =
            arbitrage.getUniswapFeeQuote(currentConfig.usdc, 0x4200000000000000000000000000000000000006, 10, 3000);
        console.log(fee);
        // Setup swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: currentConfig.usdc,
            tokenOut: 0x4200000000000000000000000000000000000006,
            fee: uint24(3000),
            recipient: owner,
            deadline: block.timestamp,
            amountIn: 2,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        vm.startPrank(owner);
        IERC20(currentConfig.usdc).approve(currentConfig.uniswapRouter, 2);

        // uint256 amountOut = arbitrage._swapOnV3{value: 0.001 ether}(
        //     currentConfig.uniswapRouter,
        //     currentConfig.usdc,
        //     10,
        //     0x4200000000000000000000000000000000000006,
        //     0,
        //     3000
        // );

        // Perform swap
        // vm.selectFork(baseSepoliaFork);
        // uint256 amountOut = ISwapRouter(currentConfig.uniswapRouter)
        //     .exactInputSingle{value: fee + 0.001 ether}(params);
        vm.stopPrank();

        // assertGt(amountOut, 0);
    }

    function test_swapOnV3_sushiswap() public {}
}
