// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Arbitrage} from "../src/Arbitrage.sol";
import {DeployArbitrage} from "../script/DeployArbitrage.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoterV2} from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import {IERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Swap is Script {
    Arbitrage public arbitrage;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig currentConfig;

    function setUp() public {
        helperConfig = new HelperConfig();
        currentConfig = helperConfig.getBaseSepoliaConfig();
    }

    function run() public {
        // arbitrage = new DeployArbitrage().run();
        arbitrage = Arbitrage(payable(0xB734D543d84a7Ea8E6b603Ed6C8D12fcD2Ba7982));
        // Setup swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            tokenOut: 0x4200000000000000000000000000000000000006,
            fee: 3000,
            recipient: 0x12B2434a1022d5787bf06056F2885Fe35De62Bf8,
            deadline: block.timestamp * 2,
            amountIn: 1000000,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        vm.startBroadcast();
        // uint256 amountOut = arbitrage._swapOnV3(
        //     currentConfig.uniswapRouter,
        //     currentConfig.usdc,
        //     2000000,
        //     0x4200000000000000000000000000000000000006,
        //     0,
        //     3000
        // );
        IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e).approve(0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4, 1000000);
        console.log(
            "approval",
            IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e).allowance(
                msg.sender, 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4
            )
        );
        // Perform swap
        uint256 amountOut =
            ISwapRouter(0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4).exactInputSingle{value: 1000000000000000}(params);
        vm.stopBroadcast();
        console.log("amount out", amountOut);
    }
}
