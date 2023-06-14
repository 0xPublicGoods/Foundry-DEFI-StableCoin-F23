// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * Imports
 */
import {Script} from "forge-std/Script.sol";
import {DecentralisedStableCoin} from "../src/DecentralisedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralisedStableCoin, DSCEngine) {
        HelperConfig config = new HelperConfig();

        (address wEthUsdPiceFeed, address wBtcUsdPriceFeed, address wEth, address wBtc, uint256 deployerKey) =
            config.activeNetworkConfig();

        tokenAddresses = [wEth, wBtc];
        priceFeedAddresses = [wEthUsdPiceFeed, wBtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        DecentralisedStableCoin dsc = new DecentralisedStableCoin();

        DSCEngine engine = new DSCEngine(    
            tokenAddresses,
            priceFeedAddresses,
            address(dsc)
        );

        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();

        return (dsc, engine);
    }
}
