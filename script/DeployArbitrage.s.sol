// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Arbitrage} from "../src/Arbitrage.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployArbitrage is Script {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig modeConfig;
    HelperConfig.ForkNetworkConfig SepoliaConfig;
    Arbitrage public arbitrage;

    function setUp() public {
        helperConfig = new HelperConfig();
        modeConfig = helperConfig.getModeSepoliaConfig();
    }

    function run() public returns (Arbitrage) {
        vm.startBroadcast();
        arbitrage = new Arbitrage();
        vm.stopBroadcast();

        console2.log("Arbitrage contract deployed to:", address(arbitrage));
        return arbitrage;
    }
}
