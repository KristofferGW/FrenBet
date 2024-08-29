// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Betting {
    struct Bet {
        uint256 matchId;
        string predictedOutcome;
    }

    struct BetSlip {
        address better;
        uint256 betSlipId;
        Bet[] bets;
        uint256 groupId;
        uint256 score;
    }

    struct Group {
        uint256 balance;
        uint256 groupId;
        bool settled;
    }

    uint256 public betSlipCounter;
    uint256 public groupCounter;
    mapping(uint256 => BetSlip) public betSlips; // Mapping to store bet slips by their unique ID
    mapping(uint256 => Group) public groups; // Mapping to store groups by their unique ID
    mapping(address => uint256[]) public userBetSlips; // Mapping to store bet slip IDs by user address
    IERC20 public usdcToken; // USDC token contract

    event BetSlipCreated(address indexed better, uint256 indexed betSlipId);
    event GroupSettled(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
    }

    // Function to create a new bet slip and associate it with a group
    function createBetSlip(uint256 groupId, uint256[] memory matchIds, string[] memory predictedOutcomes) public {
        require(matchIds.length == predictedOutcomes.length, "Mismatched inputs");
        require(groups[groupId].groupId == groupId, "Invalid group ID");
        require(usdcToken.balanceOf(msg.sender) >= BET_COST, "Insufficient USDC balance");

        bool success = usdcToken.transferFrom(msg.sender, address(this), BET_COST);
        require(success, "USDC transfer failed");

        // Create a new BetSlip
        BetSlip storage newBetSlip = betSlips[betSlipCounter];
        newBetSlip.better = msg.sender;
        newBetSlip.betSlipId = betSlipCounter;
        newBetSlip.groupId = groupId;

        // Populate the bets array in the BetSlip struct
        for (uint256 i; i < matchIds.length; i++) { // is it cheaper not look up the length every time even though it's from memory?
            newBetSlip.bets.push(Bet({
                matchId: matchIds[i],
                predictedOutcome: predictedOutcomes[i]
            }));
        }

        // Store the bet slip ID in the user's record and the group
        userBetSlips[msg.sender].push(betSlipCounter);
        groups[groupId].betSlips.push(betSlipCounter);

        // Update the group's total bet amount
        groups[groupId].totalBetAmount += BET_COST;

        emit BetSlipCreated(msg.sender, betSlipCounter, groupId);

        betSlipCounter++;
    }

    function createGroup() internal {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        newGroup.settled = false;
        return newGroup;
    }

    // Function to get bet slips of a user
    function getBetSlipsByUser(address user) public view returns (uint256[] memory) {
        return userBetSlips[user];
    }

    // Function to get details of a specific bet slip
    function getBetSlipDetails(uint256 slipId) public view returns (BetSlip memory) {
        return betSlips[slipId];
    }

    // Function to get details of a specific group
    function getGroupDetails(uint256 groupId) public view returns (Group memory) {
        return groups[groupId];
    }
}