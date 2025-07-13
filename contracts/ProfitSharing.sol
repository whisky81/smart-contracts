// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ProfitSharing {
    uint public totalShares;
    uint public totalReleased;
    address[] public payees;
    mapping(address => uint) public shares;
    mapping(address => uint) public released;

    event PayeesAdded(address[] payees_, uint[] shares_);
    event PaymentReceived(address indexed from, uint amount);
    event PayeeReleased(address indexed to, uint amount);



    constructor(address[] memory payees_, uint[] memory shares_) {
        require(payees_.length == shares_.length, "payees and shares length mismatch");
        require(payees_.length > 0, "No payees provided");

        for (uint i = 0; i < payees_.length; i++) {
            _addPayee(payees_[i], shares_[i]);
        }
        emit PayeesAdded(payees_, shares_);
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function release(address account) public {
        require(shares[account] > 0, "Invalid account");
        uint profit = releasable(account);
        require(profit > 0, "No profit to release");

        totalReleased += profit;
        released[account] += profit;
        payable(account).transfer(profit);   
          
        emit PayeeReleased(account, profit);   
    }

    function releasable(address account) public view returns(uint) {
        uint balance = address(this).balance + totalReleased;
        uint profit = (balance * shares[account]) / totalShares - released[account];
        return profit;
    }

    function _addPayee(address payee, uint share) private {
        require(payee != address(0), "Invalid Payee");
        require(share > 0, "Share must be greater than 0");
        require(shares[payee] == 0, "Payee already add");

        payees.push(payee);
        shares[payee] = share;
        totalShares += share;
    }
}