// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract Betting {
    struct Bet {
        address better;
        uint256 matchId;
        string predictedOutcome;
    }

    struct BetSlip {
        address better;
        uint256 betSlipId;
        Bet[] bets;
    }

    uint256 betSlipId;
    mapping (uint256 => BetSlip) public betSlips;

    function createBetSlip(uint256[] memory matchIds, string[] memory predictedOutcomes) public {
        uint256 numberOfBets = matchIds.length;
        Bet[] memory betsArray;
        for (uint256 i; i < numberOfBets;) {

        }
    }
}