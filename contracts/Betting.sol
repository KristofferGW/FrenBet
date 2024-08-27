// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract Betting {
    struct Bet {
        uint256 matchId;
        string predictedOutcome;
    }

    struct BetSlip {
        address better;
        uint256 betSlipId;
        Bet[] bets;
    }

    uint256 public betSlipCounter; // why is this public?
    mapping (uint256 => BetSlip) public betSlips;
    mapping (address => uint256[]) public userBetSlips; // Mapping to store bet slip IDs by user address

    // Event to emit when a bit slip is created
    event BetSlipCreated(address indexed better, uint256 indexed betSlipId);

    // Function to create a new bet slip
    function createBetSlip(uint256[] memory matchIds, string[] memory predictedOutcomes) public {
        require(matchIds.length == predictedOutcomes.length, "Mismatched inputs");

        // Create a new empty BetSlip struct
        BetSlip storage newBetSlip = betSlips[betSlipCounter]; // what's happening here?
        newBetSlip.better = msg.sender;
        newBetSlip.betSlipId = betSlipCounter;

        // Populate the bets array in the BetSlip struct
        for (uint256 i; i < matchIds.length; i++) { // is it cheaper not look up the length every time even though it's from memory?
            newBetSlip.bets.push(Bet({
                matchId: matchIds[i],
                predictedOutcome: predictedOutcomes[i]
            }));
        }

        // Store the bet slip ID in the user's record
        userBetSlips[msg.sender].push(betSlipCounter);

        emit BetSlipCreated(msg.sender, betSlipCounter);

        betSlipCounter++;
    }

    // Function to get bet slips of a user
    function getBetSlipsByUser(address user) public view returns (uint256[] memory) {}
}