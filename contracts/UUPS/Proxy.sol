// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Proxy {
    address public implementation;
    address public admin;
    string public word;

    constructor(address _implementation, address _admin) {
        implementation = _implementation;
        admin = _admin;
    }

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "Failed");
    }
}

contract Logic1 {
    address public implementation;
    address public admin;
    string public word;

    function foo() external {
        word = "old";
    }

    function upgrade(address newImplementation) external {
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}

contract Logic2 {
    address public implementation;
    address public admin;
    string public word;

    function foo() external {
        word = "new";
    }

    function upgrade(address newImplementation) external {
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}