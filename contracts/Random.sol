// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Random {

    function getRandomOnChain() public view returns(uint256) {
        bytes32 hash = keccak256(abi.encodePacked(
            block.timestamp, msg.sender, blockhash(block.number - 1)));


        return uint256(hash);
    }
}