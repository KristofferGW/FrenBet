// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Converters} from "../src/Converters.sol";

contract testByteToStringConverter is Test {
    Converters public converters;

    bytes public TEST_BYTES = hex"546869732069732061207465737420737472696e67";
    string public NUMERIC_STRING = "13";
    string public STRINGTOCONVERT = "a,b,c";
    string[] public ARRAYFROMSTRING = ["a", "b", "c"];

    function setUp() public {
        converters = new Converters();
    }

    function testBytesToString() public view {
        string memory convertedStringFromBytes = converters.bytesToString(TEST_BYTES);
        console.log(convertedStringFromBytes);
        assertEq(convertedStringFromBytes, "This is a test string");
    }

    function testSplitString() public view {
        string[] memory stringConvertedToArray = converters.splitString(STRINGTOCONVERT);
        assertEq(stringConvertedToArray, ARRAYFROMSTRING);
    }

    function testStringToUint() public view {
        uint256 convertedUintFromString = converters.stringToUint(NUMERIC_STRING);
        console.log(convertedUintFromString);
        assertEq(convertedUintFromString, 13);
    }
}
