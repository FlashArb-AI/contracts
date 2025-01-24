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
    struct NetworkConfig {
        address weth;
        address usdc;
        address uniswapFactory; //Uniswap V3
        address uniswapRouter; //Uniswap V3
        address uniswapQuoter;
        address sushiswapFactory;
        address sushiswapRouter;
        address sushiswapQuoter;
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/
    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            uniswapFactory: 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,
            uniswapRouter: 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            uniswapQuoter: 0xC5290058841028F1614F3A6F0F5816cAd0df5E27,
            sushiswapFactory: address(0),
            sushiswapRouter: address(0),
            sushiswapQuoter: address(0)
        });
        return SepoliaConfig;
    }

    function getETHSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            weth: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14,
            usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            uniswapFactory: 0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            uniswapRouter: 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E,
            uniswapQuoter: 0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3,
            sushiswapFactory: address(0),
            sushiswapRouter: 0x93c31c9C729A249b2877F7699e178F4720407733,
            sushiswapQuoter: 0x039e87AB90205F9d87c5b40d4B28e2Be45dA4a20
        });
        return SepoliaConfig;
    }

    function getModeSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            weth: address(0),
            usdc: address(0),
            uniswapFactory: 0x879A0F1E8402E37ECC56C53C55B6E02EB704eDD4,
            uniswapRouter: 0x9eE1289c21321E212994B23Bf0b4Cdc453C17EEE,
            uniswapQuoter: address(0),
            sushiswapFactory: address(0),
            sushiswapRouter: address(0),
            sushiswapQuoter: address(0)
        });
        return SepoliaConfig;
    }

    function getModeMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            weth: address(0),
            usdc: 0xd988097fb8612cc24eeC14542bC03424c656005f,
            uniswapFactory: address(0),
            uniswapRouter: address(0),
            uniswapQuoter: address(0),
            sushiswapFactory: address(0),
            sushiswapRouter: 0xf2614A233c7C3e7f08b1F887Ba133a13f1eb2c55,
            sushiswapQuoter: address(0)
        });
        return SepoliaConfig;
    }

    /*//////////////////////////////////////////////////////////////
                              LOCAL CONFIG
    //////////////////////////////////////////////////////////////*/
    function getAnvilConfig() public pure returns (NetworkConfig memory) {
        console2.log("Testing On Anvil Network");
        NetworkConfig memory AnvilConfig = NetworkConfig({
            weth: address(0),
            usdc: address(1),
            uniswapFactory: address(2),
            uniswapRouter: address(3),
            uniswapQuoter: address(6),
            sushiswapFactory: address(4),
            sushiswapRouter: address(5),
            sushiswapQuoter: address(6)
        });
        return AnvilConfig;
    }
}
