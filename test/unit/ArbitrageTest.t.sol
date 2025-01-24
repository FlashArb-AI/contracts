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
        currentConfig = helperConfig.getETHSepoliaConfig();

        baseSepoliaFork = vm.createSelectFork(ETH_SEPOLIA_RPC_URL);

        vm.startPrank(owner);
        arbitrage = new Arbitrage();
        vm.stopPrank();

        deal(currentConfig.usdc, owner, 69);
        deal(currentConfig.usdc, address(arbitrage), 69);
        vm.deal(owner, 1 ether);
        vm.deal(address(arbitrage), 1 ether);
    }

    function test_swapOnV3_uniswap() public {
        vm.startPrank(owner);
        uint256 amountOut = arbitrage._swapOnV3(
            currentConfig.uniswapRouter,
            currentConfig.uniswapQuoter,
            currentConfig.usdc,
            10,
            currentConfig.weth,
            0,
            3000
        );
        vm.stopPrank();
        assertGt(amountOut, 0);
        assertGt(IERC20(currentConfig.weth).balanceOf(address(arbitrage)), 0);
        assertLt(IERC20(currentConfig.usdc).balanceOf(address(arbitrage)), 69);
    }

    // function test_swapOnV3_sushiswap() public {
    //     vm.startPrank(owner);
    //     uint256 amountOut = arbitrage._swapOnV3(
    //         currentConfig.sushiswapRouter,
    //         currentConfig.sushiswapQuoter,
    //         currentConfig.usdc,
    //         10,
    //         currentConfig.weth,
    //         0,
    //         3000
    //     );
    //     vm.stopPrank();
    //     assertGt(amountOut, 0);
    //     assertGt(IERC20(currentConfig.weth).balanceOf(address(arbitrage)), 0);
    //     assertLt(IERC20(currentConfig.usdc).balanceOf(address(arbitrage)), 69);
    // }

    function test_getUniswapFeeQuote() public {
        vm.startPrank(owner);
        uint256 fee = arbitrage.getFeeQuote(
            currentConfig.uniswapQuoter,
            currentConfig.usdc,
            currentConfig.weth,
            10,
            3000
        );
        vm.stopPrank();
        assertGt(fee, 0);
    }

    // function test_getSushiswapFeeQuote() public {
    //     vm.startPrank(owner);
    //     uint256 fee = arbitrage.getFeeQuote(
    //         currentConfig.sushiswapQuoter,
    //         currentConfig.usdc,
    //         currentConfig.weth,
    //         10000000,
    //         3000
    //     );
    //     vm.stopPrank();
    //     assertGt(fee, 0);
    // }

    function test_receiveFlashLoan() public {}
}
