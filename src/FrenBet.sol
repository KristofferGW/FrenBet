// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Converters} from "./Converters.sol";
import {FunctionsConsumer} from "./FunctionsConsumer.sol";
import {Groups} from "./Groups.sol";

contract FrenBet is Groups {
    /* Errors */
    error FrenBet__PredictorHasNoPredictionsInGroup();
    error FrenBet__GroupAlreadySettled();
    error FrenBet__GroupHasNoBalance();
    error FrenBet__InsufficientUsdc();
    error FrenBet__InvalidGroupId();
    error FrenBet__MismatchedInputs();
    error FrenBet__NoSavedResponseForGroupId();
    error FrenBet__NoWinningsToClaim();
    error FrenBet__NumResultsAndNumPredictionsDoNotMatch();
    error FrenBet__UsdcTransferFailed();

    /* Contracts */
    Converters public converters;
    FunctionsConsumer public functionsConsumer;

    /* Type declarations */
    uint256 constant BET_COST = 10;
    uint256 betCounter;
    mapping(uint256 => Bet) public betById;
    mapping(uint256 => Bet[]) public betsByGroupId; // Mapping to store Bets by groupId
    mapping(address => Bet[]) private betsByAddressesInGroup; // Used by settleBets()
    mapping(uint256 => string) public matchResultsByMatchId; // Mapping match results to match ID
    mapping(address => Bet[]) public betsByAddress; // Mapping to store bets by user address
    mapping(address => bool) private addressIsUnique; // Used in getUniqueBetters() to find unique addresses
    mapping(address => string[]) private predictedOutcomesByAddress; // Used by settleBets()
    mapping(address => uint256) public pendingWinnings;

    uint256 uniqueCount = 0;
    IERC20 public usdcToken; // USDC token contract

    /* Structs */
    struct Bet {
        uint256 betId;
        address better;
        uint256 groupId;
        uint256 matchId;
        string predictedOutcome;
    }

    /* Events */
    event BetsSettled(uint256 indexed groupId, address[3] indexed topThreeBetters, uint256[3] winnings);
    event BetSlipCreated(address indexed better, uint256 indexed groupId);
    event GroupSettled(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress, address _functionsConsumerAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
        functionsConsumer = FunctionsConsumer(_functionsConsumerAddress);
    }

    // Function to create a new bet slip and associate it with a group
    function placeBets(uint256 groupId, uint256[] calldata matchIds, string[] calldata predictedOutcomes) public {
        if (matchIds.length != predictedOutcomes.length) revert FrenBet__MismatchedInputs();
        if (groups[groupId].groupId != groupId) revert FrenBet__InvalidGroupId();
        if (usdcToken.balanceOf(msg.sender) < BET_COST) revert FrenBet__InsufficientUsdc();

        bool success = usdcToken.transferFrom(msg.sender, address(this), BET_COST);
        if (!success) revert FrenBet__UsdcTransferFailed();

        for (uint256 i; i < matchIds.length; i++) {
            Bet memory newBet = Bet({
                betId: betCounter,
                better: msg.sender,
                groupId: groupId,
                matchId: matchIds[i],
                predictedOutcome: predictedOutcomes[i]
            });
            betsByGroupId[groupId].push(newBet);
            betsByAddress[msg.sender].push(newBet);
            betById[betCounter] = newBet;
            betCounter++;
        }

        groups[groupId].betters.push(msg.sender);
        // Update the group's total bet amount
        groups[groupId].balance += BET_COST;

        emit BetSlipCreated(msg.sender, groupId);
    }

    function settleBets(uint256 groupId) public {
        if (groups[groupId].settled == true) revert FrenBet__GroupAlreadySettled();
        if (groups[groupId].balance == 0) revert FrenBet__GroupHasNoBalance();

        bytes memory bytesResponse = functionsConsumer.getResponseByGroupId(groupId);
        string memory stringResponse = converters.bytesToString(bytesResponse);
        string[] memory arrayResponse = converters.splitString(stringResponse);

        address[] memory uniqueBetters = getUniqueBetters(groupId);
        uint256 uniqueBettersLength = uniqueBetters.length;

        for (uint256 i = 0; i < uniqueBettersLength; i++) {
            string[] memory predictedOutcomesByBetter = getPredictedOutcomesByAddressInGroup(uniqueBetters[i], groupId);
            uint256 correctPredictions = countCorrectPredictionsInSlip(arrayResponse, predictedOutcomesByBetter);
            addToBetterScoresMapping(groupId, uniqueBetters[i], correctPredictions);
        }

        (address[3] memory topThreeBetters,) = getTopThreeBetters(groupId);

        uint256 totalBalance = groups[groupId].balance;
        uint256 firstPlaceShare = (totalBalance * 50) / 100;
        uint256 secondPlaceShare = (totalBalance * 30) / 100;
        uint256 thirdPlaceShare = (totalBalance * 20) / 100;

        if (topThreeBetters[0] != address(0)) {
            pendingWinnings[topThreeBetters[0]] += firstPlaceShare;
        }
        if (topThreeBetters[1] != address(0)) {
            pendingWinnings[topThreeBetters[1]] += secondPlaceShare;
        }
        if (topThreeBetters[2] != address(0)) {
            pendingWinnings[topThreeBetters[2]] += thirdPlaceShare;
        }

        groups[groupId].balance -= (firstPlaceShare + secondPlaceShare + thirdPlaceShare);

        groups[groupId].settled = true;

        emit BetsSettled(groupId, topThreeBetters, [firstPlaceShare, secondPlaceShare, thirdPlaceShare]);
    }

    function betterHasBetInGroup(address better, uint256 groupId) public view returns (bool) {
       uint256 bettersInGroupLength = groups[groupId].betters.length;
       for (uint256 i; 0 < bettersInGroupLength; i++) {
        if (groups[groupId].betters[i] == better) {
            return true;
        }
       }
       return false;
    }

    function countCorrectPredictionsInSlip(string[] memory results, string[] memory predictions) public pure returns (uint256 numOfCorrectPredictions) {
        if (!(results.length == predictions.length)) revert FrenBet__NumResultsAndNumPredictionsDoNotMatch();
        uint256 resultsLength = results.length;
        for (uint256 i; i < resultsLength; i++) {
            if (keccak256(bytes(results[i])) == keccak256(bytes(predictions[i]))) {
                numOfCorrectPredictions++;
            }
        }
        return numOfCorrectPredictions;
    }

    function getBetById(uint256 betId) public view returns (Bet memory) {
        return betById[betId];
    }

    function getBetsByAddress(address user) public view returns (Bet[] memory) {
        return betsByAddress[user];
    }

    function getPredictedOutcomesByAddressInGroup(address predictor, uint256 groupId) public view returns (string[] memory) {
        Bet[] memory allBetsByPredictor = getBetsByAddress(predictor);
        uint256 numberOfBetsByAddressInGroup = 0;
        for (uint256 i = 0; i < allBetsByPredictor.length; i++) {
            if (allBetsByPredictor[i].groupId == groupId) {
                numberOfBetsByAddressInGroup++;
            }
        }

        string[] memory predictedOutcomesByPredictorInGroup = new string[](numberOfBetsByAddressInGroup);
        uint256 indexOfBetInNewArray = 0;
        for (uint256 i = 0; i < allBetsByPredictor.length; i++) {
            if (allBetsByPredictor[i].groupId == groupId) {
                predictedOutcomesByPredictorInGroup[indexOfBetInNewArray] = allBetsByPredictor[i].predictedOutcome;
                indexOfBetInNewArray++;
            }
        }
        
        return predictedOutcomesByPredictorInGroup;
    }

    function getUniqueBetters(uint256 groupId) public returns (address[] memory) {
        Bet[] memory bets = betsByGroupId[groupId];
        uint256 betCount = bets.length;

        for (uint256 i = 0; i < betCount; i++) {
            if (!addressIsUnique[bets[i].better]) {
                addressIsUnique[bets[i].better] = true;
                uniqueCount++;
            }
        }

        address[] memory groupBetters = new address[](uniqueCount);
        uint256 index = 0;

        for (uint256 i = 0; i < betCount; i++) {
            if (addressIsUnique[bets[i].better]) {
                groupBetters[index] = bets[i].better;
                addressIsUnique[bets[i].better] = false;
                index++;
            }
        }

        return groupBetters;
    }

    function withdrawRewards() public {
        uint256 winnings = pendingWinnings[msg.sender];
        if (winnings == 0) revert FrenBet__NoWinningsToClaim();

        pendingWinnings[msg.sender] = 0;
        usdcToken.transfer(msg.sender, winnings);
    }
}
