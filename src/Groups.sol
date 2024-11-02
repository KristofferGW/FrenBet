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

    function addToBetterScoresMapping(uint256 groupId, address better, uint256 score) internal {
        groups[groupId].betterScores[better] = score;
    }

    function createGroup() public {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        groupCounter++;
        emit GroupCreated(newGroup.groupId);
    }

    function getGroupById(uint256 groupId) public view returns (Group memory) {
        return groups[groupId];
    }

    function getGroupCount() public view returns (uint256) {
        return groupCounter;
    }
}
