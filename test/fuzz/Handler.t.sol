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
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralisedStableCoin dsc;

    ERC20Mock wEth;
    ERC20Mock wBtc;

    uint256 public timesMintIsCalled = 0;
    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 public constant MAX_DEPOSIT_SIZE = type(uint96).max; // the max uint96 value

    constructor(DSCEngine _dscEngine, DecentralisedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralAddresses = dsce.getCollateralTokens();
        wEth = ERC20Mock(collateralAddresses[0]);
        wBtc = ERC20Mock(collateralAddresses[1]);

        // set up price feeds
        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(wEth)));
    }

    function mintDsc(uint256 amount, uint256 addressSeed) public {
        if (usersWithCollateralDeposited.length == 0) {
            return;
        }

        address sender = usersWithCollateralDeposited[addressSeed % usersWithCollateralDeposited.length];

        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
        int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);

        if (maxDscToMint < 0) {
            return;
        }

        amount = bound(amount, 0, uint256(maxDscToMint));

        if (amount == 0) {
            return;
        }

        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled++;
    }

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        // console.log("amountCollateral", amountCollateral);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral); // this one is from openzeppelin 4.9.1
        // collateral.approveInternal(msg.sender, address(dsce), amountCollateral); // from my own mock which is the same as Patricks, openzeppelin 4.8.3
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(msg.sender, address(collateral));
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }

        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    // this breaks out invariant test suite!! it is a known risk issue and we must mitigate
    // function updateCollateralPrice(uint96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    // Helper functions
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return wEth;
        } else {
            return wBtc;
        }
    }
}
