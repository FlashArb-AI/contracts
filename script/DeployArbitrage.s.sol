// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Arbitrage} from "../src/Arbitrage.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployArbitrage is Script {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig currentConfig;
    Arbitrage public arbitrage;

    function setUp() public {
        helperConfig = new HelperConfig();
        currentConfig = helperConfig.getBaseSepoliaConfig();
    }

    function run() public returns (Arbitrage) {
        vm.startBroadcast();
        arbitrage = new Arbitrage();
        vm.stopBroadcast();
        return arbitrage;
    }
}
