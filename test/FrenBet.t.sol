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
    string[] PREDICTED_OUTCOMES_12X = ["h", "a", "d"];
    string[] PREDICTED_OUTCOMES_XX1 = ["d", "d", "h"];
    string[] PREDICTED_OUTCOMES_1X1 = ["h", "d", "h"];
    string[] PREDICTED_OUTCOMES_X2X = ["d", "a", "d"];
    string[] MATCH_RESULTS_1X1 = ["h", "d", "h"];
    address USER1 = makeAddr("User 1");
    address USER2 = makeAddr("User 2");
    address USER3 = makeAddr("User 3");
    address USER4 = makeAddr("User 4");
    address[] THREE_UNIQUE_BETTERS = [USER1, USER2, USER3];

    function setUp() public {
        owner = address(this); // Set the owner as the current contract address
        // recipient = USER1;

        fakeUSDC = new FixedToken("Fake USDC", "FUSDC", 1000 * 10 ** 18);
        fakeUSDC.transfer(USER1, APPROVAL_AMOUNT);
        fakeUSDC.transfer(USER2, APPROVAL_AMOUNT);
        fakeUSDC.transfer(USER3, APPROVAL_AMOUNT);
        fakeUSDC.transfer(USER4, APPROVAL_AMOUNT);
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

        vm.startPrank(USER4);
        fakeUSDC.approve(address(frenBet), APPROVAL_AMOUNT);
        vm.stopPrank();
    }

    function testBetterHasBetInGroup() public {
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
        vm.stopPrank();
        bool userHasBetInGroup = frenBet.betterHasBetInGroup(USER1, TEST_GROUP_ID);
        assertEq(userHasBetInGroup, true);
    }

    function testBetterHasNoBetInGroup() public view {
        bool userHasBetInGroup = frenBet.betterHasBetInGroup(USER1, TEST_GROUP_ID);
        assertEq(userHasBetInGroup, false);
    }

    function testCountCorrectPredictionsInSlip() public view {
        uint256 threeCorrectPredictions = frenBet.countCorrectPredictionsInSlip(MATCH_RESULTS_1X1, PREDICTED_OUTCOMES_1X1);
        uint256 twoCorrectPredictions = frenBet.countCorrectPredictionsInSlip(MATCH_RESULTS_1X1, PREDICTED_OUTCOMES_XX1);
        assertEq(threeCorrectPredictions, 3);
        assertEq(twoCorrectPredictions, 2);
    }

    function testGetPredictedOutcomesByAddressInGroup() public {
        //Arrange
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);

        //Act
        string[] memory returnedPredictedOutcomes = frenBet.getPredictedOutcomesByAddressInGroup(USER1, TEST_GROUP_ID);

        //Assert
        assertEq(returnedPredictedOutcomes, PREDICTED_OUTCOMES_12X);
    }

    function testGetTopThreeBetters() public {
        // Arrange
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
        vm.stopPrank();
        vm.startPrank(USER2);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_XX1);
        vm.stopPrank();
        vm.startPrank(USER3);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_1X1);
        vm.stopPrank();
        vm.startPrank(USER4);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_X2X);
        vm.stopPrank();
        groups.addToBetterScoresMapping(TEST_GROUP_ID, USER1, 1);
        groups.addToBetterScoresMapping(TEST_GROUP_ID, USER2, 2);
        groups.addToBetterScoresMapping(TEST_GROUP_ID, USER3, 3);
        groups.addToBetterScoresMapping(TEST_GROUP_ID, USER4, 0);
        address[3] memory expectedBetters = [USER3, USER2, USER1];
        uint8[3] memory expectedScores = [3, 2, 1];


        // Act
        (address[3] memory topThreeBetters, uint256[3] memory topThreeScores) = groups.getTopThreeBetters(TEST_GROUP_ID);


        // Assert
        for (uint256 i = 0; i < topThreeBetters.length; i++) {
            assertEq(topThreeBetters[i], expectedBetters[i]);
            assertEq(topThreeScores[i], expectedScores[i]);
        }
        // assertEq(topThreeBetters, [USER3, USER2, USER1], "Betters should be ordered 3, 2, 1");
        // assertEq(topThreeScores, [3, 2, 1], "Top three scores should be 3, 2, 1");
    }

    function testGetUniqueBetters() public {
        // testPlaceBets();
        // *****************
        // Arrange
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
        vm.startPrank(USER2);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_XX1);
        vm.startPrank(USER3);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_1X1);
        // Act
        address[] memory result = frenBet.getUniqueBetters(TEST_GROUP_ID);
        assertEq(THREE_UNIQUE_BETTERS, result);
    }

    function testPlaceBets() public {
        // Arrange
        uint256 balanceOfUserBeforeBet = fakeUSDC.balanceOf(USER1);

        // Act
        vm.startPrank(USER1);
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
        (uint256 balance,,,,) = frenBet.getGroupWithoutMapping(TEST_GROUP_ID);

        // Assert
        assertEq(
            frenBet.getBetsByAddress(USER1).length,
            THREE_MATCH_IDS.length,
            "MatchIds length and bets by address length must match"
        );
        assertEq(fakeUSDC.balanceOf(USER1), balanceOfUserBeforeBet - 10, "User balance should be reduced by BET_COST");
        assertEq(balance, 10);
    }

    function testMismatchedInputs() public {
        // Act & Assert
        vm.startPrank(USER1);
        vm.expectRevert();
        frenBet.placeBets(TEST_GROUP_ID, TWO_MATCH_IDS, PREDICTED_OUTCOMES_12X);
    }

    function testInvalidGroupId() public {
        // Act & Assert
        vm.startPrank(USER1);
        vm.expectRevert();
        frenBet.placeBets(INVALID_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
    }

    function testInsufficientUSDCBalance() public {
        // Arrange
        address noUsdcUser = makeAddr("No USDC user");

        // Act & Arrange
        vm.prank(noUsdcUser);
        vm.expectRevert();
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
    }

    function testFailedUSDCTransfer() public {
        // Arrange
        vm.prank(USER1);
        fakeUSDC.approve(address(frenBet), 0);

        // Act & Assert
        vm.prank(USER1);
        vm.expectRevert("USDC transfer failed");
        frenBet.placeBets(TEST_GROUP_ID, THREE_MATCH_IDS, PREDICTED_OUTCOMES_12X);
    }
}
