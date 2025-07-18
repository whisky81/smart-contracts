// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Caller {
    address public proxy;

    constructor(address proxy_) {
        proxy = proxy_;
    }

    function increment() external returns(uint) {
        (bool success, bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        require(success, "Call failed");

        return abi.decode(data, (uint));
    }
}