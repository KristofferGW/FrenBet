// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract ByteToStringConverter {
    function bytesToString(bytes memory byteData) public pure returns (string memory) {
        return string(byteData);
    }
}