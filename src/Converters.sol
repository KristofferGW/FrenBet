// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract Converters {
    error Converters__InvalidCharacterInString();

    function bytesToString(bytes memory byteData) public pure returns (string memory) {
        return string(byteData);
    }

    function stringToUint(string memory s) public pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            if (!(b[i] >= 0x30 && b[i] <= 0x39)) revert Converters__InvalidCharacterInString();
            result = result * 10 + (uint256(uint8(b[i])) - 48);
        }
        return result;
    }
}
