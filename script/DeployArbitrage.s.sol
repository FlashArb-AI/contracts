// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Arbitrage} from "../src/FlashArbitrage.sol";
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
    //////////////////////////////////////////////////////////////
    //                        STATE VARIABLES                  //
    //////////////////////////////////////////////////////////////

    /// @notice Instance of HelperConfig contract for network configuration management
    /// @dev Used to retrieve network-specific configuration parameters
    HelperConfig public helperConfig;

    /// @notice Configuration struct for Mode network settings
    /// @dev Contains network-specific parameters like addresses and configuration values
    HelperConfig.NetworkConfig modeConfig;

    /// @notice Configuration struct for Sepolia testnet settings
    /// @dev Contains fork-specific parameters for testing on Sepolia network
    HelperConfig.ForkNetworkConfig SepoliaConfig;

    /// @notice The deployed FlashArbitrage contract instance
    /// @dev Main arbitrage contract that will be deployed and configured
    Arbitrage public flashArbitrage;

    //////////////////////////////////////////////////////////////
    //                        FUNCTIONS                        //
    //////////////////////////////////////////////////////////////

    /**
     * @notice Initializes the deployment script by setting up network configuration
     * @dev Creates a new HelperConfig instance and retrieves Sepolia ETH configuration
     *      This function is called automatically by Foundry before running the main deployment
     * @custom:security This function should only be called once during script initialization
     */
    function setUp() public {
        helperConfig = new HelperConfig();
        SepoliaConfig = helperConfig.getSepoliaETHConfig();
    }

    /**
     * @notice Main deployment function that deploys the FlashArbitrage contract
     * @dev Uses vm.startBroadcast() and vm.stopBroadcast() to handle transaction broadcasting
     *      The deployment is wrapped in broadcast calls to ensure proper transaction handling
     * @return flashArbitrage The deployed FlashArbitrage contract instance
     * @custom:security Ensure proper private key management when broadcasting transactions
     * @custom:gas Consider gas optimization and limit settings for mainnet deployment
     * @custom:network Verify network configuration before deployment to avoid wrong network deployment
     */
    function run() public returns (Arbitrage) {
        // Start broadcasting transactions - required for actual deployment
        vm.startBroadcast();

        // Deploy the FlashArbitrage contract with default constructor parameters
        flashArbitrage = new Arbitrage();

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed contract address for verification and future reference
        console2.log("Arbitrage contract deployed to:", address(flashArbitrage));

        return flashArbitrage;
    }
}
