// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {FlashArbitrage} from "../src/FlashArbitrage.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployArbitrage is Script {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig modeConfig;
    HelperConfig.ForkNetworkConfig SepoliaConfig;
    FlashArbitrage public flashArbitrage;

    function setUp() public {
        helperConfig = new HelperConfig();
        modeConfig = helperConfig.getModeSepoliaConfig();
    }

    function run() public returns (FlashArbitrage) {
        vm.startBroadcast();
        flashArbitrage = new FlashArbitrage();
        vm.stopBroadcast();

        console2.log("Arbitrage contract deployed to:", address(flashArbitrage));
        return flashArbitrage;
    }
}
