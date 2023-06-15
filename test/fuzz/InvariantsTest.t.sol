// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * Imports
 */
import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralisedStableCoin dsc;
    HelperConfig config;
    address wEth;
    address wBtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, wEth, wBtc,) = config.activeNetworkConfig();
        // targetContract(address(dsce));
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
        // set this up in handler.t.sol
        // dont call redeemCollateral unless there is collateral to redeem
    }

    function invariant_protocolMustHaveMoreCollateralValueThankDscSupply() public view {
        // get value of all the collateral in the protocol in usdAmount
        // compare it to all the minted dsc
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(wEth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wBtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(wEth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wBtc, totalWbtcDeposited);

        console.log("wethValue", wethValue);
        console.log("wbtcValue", wbtcValue);
        console.log("totalSupply", totalSupply);
        console.log("times mint called", handler.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
