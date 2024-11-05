// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract Groups {
    uint256 public groupCounter;

    struct Group {
        uint256 balance;
        uint256[] betIds;
        address[] betters;
        uint256 groupId;
        bool settled;
        mapping(address => uint256) betterScores;
    }

    mapping(uint256 => Group) public groups; // Mapping to store groups by their unique ID

    event GroupCreated(uint256 indexed groupId);

    function addToBetterScoresMapping(uint256 groupId, address better, uint256 score) public {
        groups[groupId].betterScores[better] = score;
    }

    function createGroup() public {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        groupCounter++;
        emit GroupCreated(newGroup.groupId);
    }

    function getGroupScores(uint256 groupId, address better) public view returns (uint256) {
        return groups[groupId].betterScores[better];
    }

    // function getGroupById(uint256 groupId) public view returns (Group memory) {
    //     return groups[groupId];
    // }

    function getGroupCount() public view returns (uint256) {
        return groupCounter;
    }

    function getGroupWithoutMapping(uint256 groupId) public view returns (
        uint256 balance,
        uint256[] memory betIds,
        address[] memory betters,
        uint256 groupIdOut,
        bool settled
    ) {
        Group storage group = groups[groupId];
        return (
            group.balance,
            group.betIds,
            group.betters,
            group.groupId,
            group.settled
        );
    }

    function getTopThreeBetters(uint256 groupId) public view returns (address[3] memory topBetters, uint256[3] memory topScores) {
        uint256 bettersLength = groups[groupId].betters.length;

        for (uint256 i = 0; i < bettersLength; i++) {
            address better = groups[groupId].betters[i];
            uint256 score = groups[groupId].betterScores[better];

            if (score > topScores[0]) {
                topScores[2] = topScores[1];
                topBetters[2] = topBetters[1];

                topScores[1] = topScores[0];
                topBetters[1] = topBetters[0];

                topScores[0] = score;
                topBetters[0] = better;
            } else if (score > topScores[1]) {
                topScores[2] = topScores[1];
                topBetters[2] = topBetters[1];

                topScores[1] = score;
                topBetters[1] = better;
            } else if (score > topScores[2]) {
                topScores[2] = score;
                topBetters[2] = better;
            }
        }

        return (topBetters, topScores);
    }
}
