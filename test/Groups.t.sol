// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Groups} from "../src/Groups.sol";

contract GroupsTest is Test, Groups {
    Groups testGroups = new Groups();

    uint8 FIRST_GROUP_ID = 0;

    function testCreateGroup() public {
        uint256 groupCountPreCreate = testGroups.getGroupCount();
        testGroups.createGroup();
        Group memory firstGroupId = testGroups.getGroupById(FIRST_GROUP_ID);
        uint256 fetchedGroupId = firstGroupId.groupId;
        uint256 groupCount = testGroups.getGroupCount();
        assertEq(fetchedGroupId, FIRST_GROUP_ID, "First group id is not 0");
        assertEq(groupCount, groupCountPreCreate + 1, "Group count is not (prev group count + 1)");
    }
}
