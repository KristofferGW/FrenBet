// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FunctionsConsumer} from "./FunctionsConsumer.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Betting {
    FunctionsConsumer public functionsConsumer;

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
        BetSlip[] betSlips;
        uint256 groupId;
        bool settled;
    }

    uint256 constant BET_COST = 10; 
    uint256 public betSlipCounter;
    uint256 public groupCounter;
    mapping(uint256 => BetSlip) public betSlips; // Mapping to store bet slips by their unique ID
    mapping(uint256 => uint256[]) public betSlipsByGroup; // Mapping to store bet slips by groupId
    mapping(uint256 => Group) public groups; // Mapping to store groups by their unique ID
    mapping(uint256 => string) public matchResults; // Mapping match results to match ID
    mapping(address => uint256[]) public userBetSlips; // Mapping to store bet slip IDs by user address
    IERC20 public usdcToken; // USDC token contract

    event BetSlipCreated(address indexed better, uint256 indexed betSlipId);
    event GroupSettled(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress, address _functionsConsumerAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
        functionsConsumer = FunctionsConsumer(_functionsConsumerAddress);
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
        for (uint256 i; i < matchIds.length; i++) {
            newBetSlip.bets.push(Bet({
                matchId: matchIds[i],
                predictedOutcome: predictedOutcomes[i]
            }));
        }

        // Store the bet slip ID in the user's record and the group
        userBetSlips[msg.sender].push(betSlipCounter);
        betSlipsByGroup[groupId].push(betSlipCounter);

        // Update the group's total bet amount
        groups[groupId].balance += BET_COST;

        emit BetSlipCreated(msg.sender, betSlipCounter);

        betSlipCounter++;
    }

    function createGroup() internal {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        newGroup.settled = false;
        groupCounter++;
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

    function requestMatchResult(uint256 matchId) internal {
        string memory source = "<Your Javascript Code>"; // How can I import this?
        bytes memory encryptedSecretUrls = "<Your Encrypted Secrets>"; // How can I import this?
        uint8 donHostedSecretsSlotId = 0; // Use the appropriate value, do I even need it when using gist?
        uint64 donHostedSecretsVersion = 0; // Use the appropriate value, do I even need it when using gist?
        string[] memory args;
        args[0] = Strings.toString(matchId); 
        bytes[] memory bytesArgs; // Empty if you don't have any bytesArgs
        uint64 subscriptionId = 1234;
        uint32 gasLimit = 300000;
        bytes32 donId = keccak256(abi.encodePacked("fun-ethereum-sepolia-1"));

        bytes32 requestId = functionsConsumer.sendRequest(
            source,
            encryptedSecretUrls,
            donHostedSecretsSlotId,
            donHostedSecretsVersion,
            args,
            bytesArgs,
            subscriptionId,
            gasLimit,
            donId
        );
    }

    function settleGroup(uint256 groupId) public {
        uint256[] memory betSlipIds = betSlipsByGroup[groupId];

        for (uint256 i = 0; i < betSlipIds.bets.length; i++) {
            uint256 matchId = betSlipIds[i];

            requestMatchResult(matchId);
        }

        // calculate scores
        // distribute winnings
    }
}