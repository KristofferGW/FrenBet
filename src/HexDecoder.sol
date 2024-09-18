// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract HexDecoder {
    // The hex string without the 0x prefix
    string hexString = "642c642c682c642c642c612c612c642c682c642c682c612c682c682c642c612c682c682c642c682c682c642c612c682c642c612c642c682c642c682c612c682c612c642c682c682c612c642c682c682c612c682c682c612c682c612c612c682c682c68";

    // Function to decode the hex string into a readable format
    function decodeHexString() public view returns (string memory) {
        bytes memory = hexBytes(hexString);
        bytes memory decodedBytes = new bytes(hex.bytes.length / 2);

        for (uint256 i = 0; i < hexBytes.length; i += 3) {
            decodedBytes[i / 3] = bytes1(uint8(parseHexByte(hexBytes[i], hexBytes[i + 1])));
        }
    }
}