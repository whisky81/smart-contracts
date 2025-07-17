// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLocker {

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable startTime;
    uint256 public immutable timeLock;

    event TokenLockStart(
        address indexed token, 
        address indexed beneficiary,
        uint256 startTime,
        uint256 timeLock
    );

    event Release(
        address indexed token,
        address indexed beneficiary,
        uint256 releaseTime,
        uint256 amount
    );

    constructor(address token_, address beneficiary_, uint256 timeLock_) {
        require(timeLock_ > 0, "TokenLocker: Lock time should greater than 0");

        token = IERC20(token_);
        beneficiary = beneficiary_;
        startTime = block.timestamp;
        timeLock = timeLock_;

        emit TokenLockStart(token_, beneficiary_, startTime, timeLock_);
    }

    function release() public {
        require(startTime + timeLock <= block.timestamp, "TokenLock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLocker: No tokens to release");

        token.transfer(beneficiary, amount);
        emit Release(address(token), beneficiary, block.timestamp, amount);
    }
}