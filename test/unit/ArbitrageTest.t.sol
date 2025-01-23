// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {Arbitrage} from "../../src/Arbitrage.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ArbitrageTest is Test {
    Arbitrage public arbitrage;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig currentConfig;
    address owner = address(1);
    uint256 sepoliaFork;

    string ETH_SEPOLIA_RPC_URL = vm.envString("ETH_SEPOLIA_RPC_URL");

    function setUp() public {
        helperConfig = new HelperConfig();
        currentConfig = helperConfig.getETHSepoliaConfig();
        vm.startPrank(owner);
        sepoliaFork = vm.createSelectFork(ETH_SEPOLIA_RPC_URL);
        arbitrage = new Arbitrage();
        vm.stopPrank();
        deal(currentConfig.usdc, owner, 69);
        vm.deal(owner, 1 ether);
    }

    function test_swapOnV3_uniswap() public {
        console.log(IERC20(currentConfig.usdc).balanceOf(owner));
        vm.startPrank(owner);
        vm.selectFork(sepoliaFork);
        IERC20(currentConfig.usdc).approve(address(arbitrage), 10);
        uint256 amountOut = arbitrage._swapOnV3{value: 0.1 ether}(
            currentConfig.uniswapRouter,
            currentConfig.usdc,
            10,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            1,
            10
        );
        vm.stopPrank();

        assertGt(amountOut, 0);
    }

    function test_swapOnV3_sushiswap() public {}
}
