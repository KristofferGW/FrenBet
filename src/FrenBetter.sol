// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {FunctionsConsumer} from "./FunctionsConsumer.sol";
import {Groups} from "./Groups.sol";

contract FrenBetter is Groups {
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
    mapping(uint256 => Bet[]) public betsByGroupId; // Mapping to store Bets by groupId
    mapping(uint256 => string) public matchResultsByMatchId; // Mapping match results to match ID
    mapping(address => uint256[]) public betsByAddress; // Mapping to store bets by user address
    IERC20 public usdcToken; // USDC token contract

    event GroupSettled(uint256 indexed groupId);

    // Constructor to set the USDC token contract address
    constructor(address _usdcTokenAddress, address _functionsConsumerAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
        functionsConsumer = FunctionsConsumer(_functionsConsumerAddress);
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
            betsByAddress[msg.sender].push(betCounter);
            betCounter++;
        }

        // Update the group's total bet amount
        groups[groupId].balance += BET_COST;
    }

    // function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) public {

    // }

    // // Function to get bet slips of a user
    // function getBetSlipsByUser(address user) public view returns (uint256[] memory) {
    //     return userBetSlips[user];
    // }

    // // Function to get details of a specific bet slip
    // function getBetDetails(uint256 slipId) public view returns (BetSlip memory) {
    //     return betSlips[slipId];
    // }

    // // Function to get details of a specific group
    // function getGroupDetails(uint256 groupId) public view returns (Group memory) {
    //     return groups[groupId];
    // }

    // function requestMatchResult(uint256 matchId) internal {
    //     string memory source = "<Your Javascript Code>"; // How can I import this?
    //     bytes memory encryptedSecretUrls = "<Your Encrypted Secrets>"; // How can I import this?
    //     uint8 donHostedSecretsSlotId = 0; // Use the appropriate value, do I even need it when using gist?
    //     uint64 donHostedSecretsVersion = 0; // Use the appropriate value, do I even need it when using gist?
    //     string[] memory args;
    //     args[0] = Strings.toString(matchId); 
    //     bytes[] memory bytesArgs; // Empty if you don't have any bytesArgs
    //     uint64 subscriptionId = 1234;
    //     uint32 gasLimit = 300000;
    //     bytes32 donId = keccak256(abi.encodePacked("fun-ethereum-sepolia-1"));

    //     bytes32 requestId = functionsConsumer.sendRequest(
    //         source,
    //         encryptedSecretUrls,
    //         donHostedSecretsSlotId,
    //         donHostedSecretsVersion,
    //         args,
    //         bytesArgs,
    //         subscriptionId,
    //         gasLimit,
    //         donId
    //     );
    // }

    // function settleGroup(uint256 groupId) public {
    //     uint256[] memory betSlipIds = bets[groupId];

    //     for (uint256 i = 0; i < betSlipIds.bets.length; i++) {
    //         uint256 matchId = betSlipIds[i];

    //         requestMatchResult(matchId);
    //     }

    //     // calculate scores
    //     // distribute winnings
    // }
}