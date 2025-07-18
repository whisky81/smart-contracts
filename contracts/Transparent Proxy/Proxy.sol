// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Proxy {
    address public implementation;
    address public admin;

    string public name;
    event Selector(bytes4 selector);

    constructor(address implementation_, address admin_) {
        implementation = implementation_;
        admin = admin_;
    }

    fallback() external {
        require(msg.sender != admin, "-Admin");
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "Failed");
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == admin, "Only Admin");
        implementation = newImplementation;
    }

}