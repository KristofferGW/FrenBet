// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Groups} from "../src/Groups.sol";

contract GroupsTest is Test, Groups {
    Groups testGroups = new Groups();

    uint8 FIRST_GROUP_ID = 0;
    address USER1 = makeAddr("User 1");
    uint8 EXPECTED_SCORE = 3;

    function testAddToBetterScoresMapping() public {
        testGroups.createGroup();
        testGroups.addToBetterScoresMapping(1, USER1, 3);
        uint256 user1Score = testGroups.getBetterScore(1, USER1);
        assertEq(user1Score, EXPECTED_SCORE);
    }

    function testCreateGroup() public {
        uint256 groupCountPreCreate = testGroups.getGroupCount();
        testGroups.createGroup();
        (, , , uint256 groupId,) = testGroups.getGroupWithoutMapping(FIRST_GROUP_ID);
        uint256 groupCount = testGroups.getGroupCount();
        assertEq(groupId, FIRST_GROUP_ID, "First group id is not 0");
        assertEq(groupCount, groupCountPreCreate + 1, "Group count is not (prev group count + 1)");
    }
}
