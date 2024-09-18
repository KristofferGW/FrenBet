// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract Groups {
    struct Group {
        uint256 balance;
        uint256[] betIds;
        uint256 groupId;
        bool settled;
    }

    uint256 public groupCounter;

    mapping(uint256 => Group) public groups; // Mapping to store groups by their unique ID

    function createGroup() public {
        Group storage newGroup = groups[groupCounter];
        newGroup.groupId = groupCounter;
        groupCounter++;
    }

    function getGroupById(uint256 groupId) public view returns (Group memory) {
        return groups[groupId];
    }

    function getGroupCount() public view returns (uint256) {
        return groupCounter;
    }
}