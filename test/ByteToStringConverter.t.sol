// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {ByteToStringConverter} from "../src/ByteToStringConverter.sol";

contract testByteToStringConverter is Test {
    ByteToStringConverter public converter;

    bytes public TEST_BYTES = hex"546869732069732061207465737420737472696e67";

    function setUp() public {
        converter = new ByteToStringConverter();
    }

    function testConvertBytes() public {
        string memory convertedStringFromBytes = converter.bytesToString(TEST_BYTES);
        console.log(convertedStringFromBytes);
        assertEq(convertedStringFromBytes, "This is a test string");
    }
}