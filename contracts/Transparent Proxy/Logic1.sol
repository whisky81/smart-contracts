// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Logic1 {
    address public implementation;
    address public admin;

    string name;
    event Selector(bytes4 selector);
    // 0xc2985578
    function foo() external {
        name = "old";
        emit Selector(bytes4(keccak256("foo()")));
    }
}

contract Logic2 {
    address public implementation;
    address public admin;

    string name;
    event Selector(bytes4 selector);
    // 0xc2985578
    function foo() external {
        name = "new";
        emit Selector(bytes4(keccak256("foo()")));
    }
}

