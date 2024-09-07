// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {FunctionsConsumer} from "./FunctionsConsumer.sol";
import {Groups} from "./Groups.sol";

contract FrenBet is Groups {
    FunctionsConsumer public functionsConsumer;

    struct Bet {
        uint256 betId;
        address better;
        uint256 groupId;
        uint256 matchId;
        string predictedOutcome;
    }

    uint256 constant BET_COST = 10; 
    uint256 betCounter;
    mapping(uint256 => Bet) public betById;
    mapping(uint256 => Bet[]) public betsByGroupId; // Mapping to store Bets by groupId
    mapping(uint256 => string) public matchResultsByMatchId; // Mapping match results to match ID
    mapping(address => Bet[]) public betsByAddress; // Mapping to store bets by user address
    IERC20 public usdcToken; // USDC token contract

    event GroupSettled(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress, address _functionsConsumerAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
        functionsConsumer = FunctionsConsumer(_functionsConsumerAddress);
    }

    function getBetById(uint256 betId) public view returns (Bet memory) {
        return betById[betId];
    }

    function getBetsByAddress(address user) public view returns (Bet[] memory) {
        return betsByAddress[user];
    }

    // Function to create a new bet slip and associate it with a group
    function placeBets(uint256 groupId, uint256[] calldata matchIds, string[] calldata predictedOutcomes) public {
        require(matchIds.length == predictedOutcomes.length, "Mismatched inputs");
        require(groups[groupId].groupId == groupId, "Invalid group ID");
        require(usdcToken.balanceOf(msg.sender) >= BET_COST, "Insufficient USDC balance");

        bool success = usdcToken.transferFrom(msg.sender, address(this), BET_COST);
        require(success, "USDC transfer failed");

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

        // Update the group's total bet amount
        groups[groupId].balance += BET_COST;
    }

    function settleBets(uint256 groupId) public {
        // 
    }
}