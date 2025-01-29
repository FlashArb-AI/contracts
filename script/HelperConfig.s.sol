// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct ForkNetworkConfig {
        address weth; // Base Network WETH
        address usdc; // Base Network USDC
        address uniswapFactory; // Uniswap V3
        address uniswapRouter; // Uniswap V3
        address uniswapQuoter; // Uniswap V3
        address pancakeSwapFactory; // PankcakeSwap V3
        address pancakeSwapRouter; // PankcakeSwap V3
        address pancakeSwapQuoter; // PankcakeSwap V3
    }

    struct NetworkConfig {
        address weth; // Mode Network WETH
        address usdc; // Mode Network USDC
        address velodromeFinanceFactory; // Need To Find Mode Supported DEX
        address velodromeFinanceRouter; //Need To Find Mode Supported DEX
        address velodromeFinanceQuoter; // Need To Find Mode Supported DEX
        address sushiSwapFactory; // Sushiswap V3
        address sushiSwapRouter; // Sushiswap V3
        address sushiSwapQuoter; // Sushiswap V3
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/
    function getSepoliaETHConfig() public pure returns (ForkNetworkConfig memory) {
        ForkNetworkConfig memory SepoliaConfig = ForkNetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            uniswapFactory: 0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            uniswapRouter: 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E,
            uniswapQuoter: 0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3,
            pancakeSwapFactory: 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865,
            pancakeSwapRouter: 0x1b81D678ffb9C0263b24A97847620C99d213eB14,
            pancakeSwapQuoter: 0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997
        });
        return SepoliaConfig;
    }

    function getBaseSepoliaConfig() public pure returns (ForkNetworkConfig memory) {
        ForkNetworkConfig memory BaseSepoliaConfig = ForkNetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            uniswapFactory: 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,
            uniswapRouter: 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            uniswapQuoter: 0xC5290058841028F1614F3A6F0F5816cAd0df5E27,
            pancakeSwapFactory: 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865,
            pancakeSwapRouter: 0x1b81D678ffb9C0263b24A97847620C99d213eB14,
            pancakeSwapQuoter: 0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997
        });
        return BaseSepoliaConfig;
    }

    function getModeMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ModeConfig = NetworkConfig({
            weth: address(0),
            usdc: 0xd988097fb8612cc24eeC14542bC03424c656005f,
            velodromeFinanceFactory: 0xCc0bDDB707055e04e497aB22a59c2aF4391cd12F,
            velodromeFinanceRouter: 0x0792a633F0c19c351081CF4B211F68F79bCc9676,
            velodromeFinanceQuoter: 0x89D8218ed5fF1e46d8dcd33fb0bbeE3be1621466,
            sushiSwapFactory: address(0),
            sushiSwapRouter: 0xf2614A233c7C3e7f08b1F887Ba133a13f1eb2c55,
            sushiSwapQuoter: address(0)
        });
        return ModeConfig;
    }

    /*//////////////////////////////////////////////////////////////
                              LOCAL CONFIG
    //////////////////////////////////////////////////////////////*/
    function getAnvilConfig() public pure returns (ForkNetworkConfig memory) {
        console2.log("Testing On Anvil Network");
        ForkNetworkConfig memory AnvilConfig = ForkNetworkConfig({
            weth: address(0),
            usdc: address(1),
            uniswapFactory: address(2),
            uniswapRouter: address(3),
            uniswapQuoter: address(6),
            pancakeSwapFactory: address(4),
            pancakeSwapRouter: address(5),
            pancakeSwapQuoter: address(6)
        });
        return AnvilConfig;
    }
}
