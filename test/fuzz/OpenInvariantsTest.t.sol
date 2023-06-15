// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.19;

// /**
//  * Imports
//  */
// import {Test, console} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract OpenInvariantsTest is StdInvariant, Test {
//     DeployDSC deployer;
//     DSCEngine dsce;
//     DecentralisedStableCoin dsc;
//     HelperConfig config;
//     address wEth;
//     address wBtc;

//     function setUp() external {
//         deployer = new DeployDSC();
//         (dsc, dsce, config) = deployer.run();
//         (,, wEth, wBtc,) = config.activeNetworkConfig();
//         targetContract(address(dsce));
//     }

//     function invariant_protocolMustHaveMoreCollateralValueThankDscSupply() public view {
//         // get value of all the collateral in the protocol in usdAmount
//         // compare it to all the minted dsc
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(wEth).balanceOf(address(dsce));
//         uint256 totalWbtcDeposited = IERC20(wBtc).balanceOf(address(dsce));

//         uint256 wethValue = dsce.getUsdValue(wEth, totalWethDeposited);
//         uint256 wbtcValue = dsce.getUsdValue(wBtc, totalWbtcDeposited);
//         assert(wethValue + wbtcValue >= totalSupply);
//     }
// }
