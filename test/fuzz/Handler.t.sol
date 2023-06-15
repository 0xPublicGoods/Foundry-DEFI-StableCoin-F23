// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * Imports
 */
import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
//import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralisedStableCoin dsc;

    ERC20Mock wEth;
    ERC20Mock wBtc;

    uint256 public constant MAX_DEPOSIT_SIZE = type(uint96).max; // the max uint96 value

    constructor(DSCEngine _dscEngine, DecentralisedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralAddresses = dsce.getCollateralTokens();
        wEth = ERC20Mock(collateralAddresses[0]);
        wBtc = ERC20Mock(collateralAddresses[1]);
    }

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        console.log("amountCollateral", amountCollateral);

        vm.prank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        // collateral.approveInternal(msg.sender, address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return wEth;
        } else {
            return wBtc;
        }
    }
}
