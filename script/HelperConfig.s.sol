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
        address uniswapFactory; // Uniswap V3
        address uniswapRouter; //Uniswap V3
        address uniswapQouter; // Uniswap V3
        address forkedUniswapFactory; // Forked Uniswap V3
        address forkedUniswapRouter; // Forked Uniswap V3
        address forkedUniswapQouter; // Forked Uniswap V3
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

    function getModeSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ModeConfig = NetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x448A7D1dA6C7a9027caAC6f05309fa42361487E0,
            uniswapFactory: 0x879A0F1E8402E37ECC56C53C55B6E02EB704eDD4,
            uniswapRouter: 0x9eE1289c21321E212994B23Bf0b4Cdc453C17EEE,
            uniswapQouter: 0xb18D334d3c1e1F3D21B8cAeCBFc705B03373E2F8,
            forkedUniswapFactory: 0x89F7868a9D66962906D29350C5957c1Ca5d8843b,
            forkedUniswapRouter: 0x9eE1289c21321E212994B23Bf0b4Cdc453C17EEE,
            forkedUniswapQouter: 0x095781EF06536DE360E9fb6218656d6845b0A3bC
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
