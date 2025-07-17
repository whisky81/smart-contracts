// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Logic {
    address public implementation;
    uint public x = 99;
    event CallSuccess();

    // 0xd09de08a
    function increment() external returns(uint) {
        emit CallSuccess();        
        return x + 1;
    }
}
