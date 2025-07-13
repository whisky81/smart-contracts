// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVesting {
    uint public immutable start;
    uint public immutable duration;
    address public immutable beneficiary;
    mapping(address => uint) public erc20Released;

    event Erc20Released(address indexed token, uint amount);

    constructor(address _beneficiary, uint _durationSeconds) {
        start = block.timestamp;
        duration = _durationSeconds;
        beneficiary = _beneficiary;
    }

    function release(address token) public {
        uint releasable = vestedAmount(token) - erc20Released[token];

        erc20Released[token] += releasable;
        IERC20(token).transfer(msg.sender, releasable);
        emit Erc20Released(token, releasable);
    }

    function vestedAmount(address token) public view returns(uint) {
        uint totalAllowcation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        
        uint timestamp = block.timestamp;
        if (timestamp < start) {
            return 0;
        } else if (start + duration < timestamp) {
            return totalAllowcation;
        } else {
            return totalAllowcation * (timestamp - start) / duration;
        }
    }
}