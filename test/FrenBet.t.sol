// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FixedToken} from "../test/FixedToken.sol";
import {FrenBet} from "../src/FrenBet.sol";
import {Groups} from "../src/Groups.sol";

contract FrenBetTest is Test {
    FixedToken public fakeUSDC;
    FrenBet public frenBet;
    Groups public groups;

    address owner;
    address recipient;
    uint256 APPROVAL_AMOUNT = 1000;
    uint256 TEST_GROUP_ID = 1;
    uint256 INVALID_GROUP_ID = 3;
    address FUNCTIONS_CONSUMER_ADDRESS = makeAddr("Functions consumer address");
    uint256[] THREE_MATCH_IDS = [3432, 334, 3];
    uint256[] TWO_MATCH_IDS = [3432, 334];
    string[] PREDICTED_OUTCOUMES_12X = ["h", "a", "d"];
    string[] PREDICTED_OUTCOUMES_XX1 = ["d", "d", "h"];
    string[] PREDICTED_OUTCOUMES_1X1 = ["h", "d", "h"];
    address USER1 = makeAddr("User 1");
    address USER2 = makeAddr("User 2");
    address USER3 = makeAddr("User 3");
    address[] THREE_UNIQUE_BETTERS = [USER1, USER2, USER3];

    function setUp() public {
        owner = address(this); // Set the owner as the current contract address
        // recipient = USER1;

        fakeUSDC = new FixedToken("Fake USDC", "FUSDC", 1000 * 10 ** 18);
        fakeUSDC.transfer(USER1, APPROVAL_AMOUNT);
        fakeUSDC.transfer(USER2, APPROVAL_AMOUNT);
        fakeUSDC.transfer(USER3, APPROVAL_AMOUNT);
        frenBet = new FrenBet(address(fakeUSDC), FUNCTIONS_CONSUMER_ADDRESS);

        vm.startPrank(USER1);
        fakeUSDC.approve(address(frenBet), APPROVAL_AMOUNT);
        frenBet.createGroup();
        frenBet.createGroup();
        vm.stopPrank();

        vm.startPrank(USER2);
        fakeUSDC.approve(address(frenBet), APPROVAL_AMOUNT);
        vm.stopPrank();

        vm.startPrank(USER3);
        fakeUSDC.approve(address(frenBet), APPROVAL_AMOUNT);
        vm.stopPrank();
    }

    function testGetPredictedOutcomesByAddressInGroup() public {
        //Arrange
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);

        //Act
        string[] memory returnedPredictedOutcomes = frenBet.getPredictedOutcomesByAddressInGroup(USER1);

        //Assert
        assertEq(returnedPredictedOutcomes, PREDICTED_OUTCOUMES_12X);
    }

    function testGetUniqueBetters() public {
        // testPlaceBets();
        // *****************
        // Arrange
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);
        vm.startPrank(USER2);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_XX1);
        vm.startPrank(USER3);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_1X1);
        // Act
        address[] memory result = frenBet.getUniqueBetters(TEST_GROUP_ID);
        assertEq(THREE_UNIQUE_BETTERS, result);
    }

    function testPlaceBets() public {
        // Arrange
        uint256 balanceOfUserBeforeBet = fakeUSDC.balanceOf(USER1);

        // Act
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);

        // Assert
        assertEq(
            frenBet.getBetsByAddress(USER1).length,
            THREE_MATCH_IDS.length,
            "MatchIds length and bets by address length must match"
        );
        assertEq(fakeUSDC.balanceOf(USER1), balanceOfUserBeforeBet - 10, "User balance should be reduced by BET_COST");
        assertEq(frenBet.getGroupById(TEST_GROUP_ID).balance, 10);
    }

    function testMismatchedInputs() public {
        // Act & Assert
        vm.startPrank(USER1);
        vm.expectRevert();
        frenBet.placeBets(TEST_GROUP_ID, TWO_MATCH_IDS, PREDICTED_OUTCOUMES_12X);
    }

    function testInvalidGroupId() public {
        // Act & Assert
        vm.startPrank(USER1);
        vm.expectRevert();
        frenBet.placeBets(INVALID_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);
    }

    function testInsufficientUSDCBalance() public {
        // Arrange
        address noUsdcUser = makeAddr("No USDC user");

        // Act & Arrange
        vm.prank(noUsdcUser);
        vm.expectRevert();
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);
    }

    function testFailedUSDCTransfer() public {
        // Arrange
        vm.prank(USER1);
        fakeUSDC.approve(address(frenBet), 0);

        // Act & Assert
        vm.prank(USER1);
        vm.expectRevert("USDC transfer failed");
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOUMES_12X);
    }
}
