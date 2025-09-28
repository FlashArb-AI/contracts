// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Arbitrage} from "../src/FlashArbitrage.sol";
import {DeployArbitrage} from "../script/DeployArbitrage.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Swap is Script {
    Arbitrage public arbitrage;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig currentConfig;

    // function setUp() public {
    //     helperConfig = new HelperConfig();
    //     currentConfig = helperConfig.getModeSepoliaConfig();
    //     arbitrage = Arbitrage(payable(address(0)));
    // }

    // function run() public {
    //     vm.startBroadcast();
    //     bool success = IERC20(currentConfig.usdc).transfer(
    //         address(arbitrage),
    //         2000000
    //     );

    //     console.log("transfer usdc to arbitrage contract", success);

    //     uint256 amountOut = arbitrage._swapOnV3(
    //         currentConfig.uniswapRouter,
    //         currentConfig.uniswapQuoter,
    //         currentConfig.usdc,
    //         2000000,
    //         0x4200000000000000000000000000000000000006,
    //         0,
    //         3000
    //     );

    //     console.log("amount swapped", amountOut);
    //     vm.stopBroadcast();
    // }
}
