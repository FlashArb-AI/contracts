// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {FlashArbitrage} from "../src/FlashArbitrage.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/**
 * @title DeployArbitrage
 * @author FlashArbAI
 * @notice This contract is responsible for deploying the FlashArbitrage contract
 * @dev Deployment script that uses Foundry's Script contract for deploying FlashArbitrage
 *      The script configures network settings using HelperConfig and deploys the arbitrage contract
 *      with proper broadcasting for mainnet/testnet deployment
 */
contract DeployArbitrage is Script {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig modeConfig;
    HelperConfig.ForkNetworkConfig SepoliaConfig;
    FlashArbitrage public flashArbitrage;

    function setUp() public {
        helperConfig = new HelperConfig();
        modeConfig = helperConfig.getSepoliaETHConfig();
    }

    function run() public returns (FlashArbitrage) {
        vm.startBroadcast();
        flashArbitrage = new FlashArbitrage();
        vm.stopBroadcast();

        console2.log("Arbitrage contract deployed to:", address(flashArbitrage));
        return flashArbitrage;
    }
}
