// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FrenBetter} from "../src/FrenBetter.sol";

contract FrenBetterTest is Test {
    FrenBetter public frenBetter;
    address USDC_TOKEN_ADDRESS = makeAddr("USDC token address");
    address FUNCTIONS_CONSUMER_ADDRESS = makeAddr("Functions consumer address");

    function setUp() public {
        frenBetter = new Betting(USDC_TOKEN_ADDRESS, FUNCTIONS_CONSUMER_ADDRESS);
    }

    function testCreateGroup() public {
        uint256 groupCountarAfterCreate;
        uint256 groupCounterBeforeCreate = frenBetter.getGroupCount();
        frenBetter.createGroup();
        groupCountarAfterCreate = frenBetter.getGroupCount();
        assertEq(groupCounterBeforeCreate + 1, groupCountarAfterCreate);
    }
}
