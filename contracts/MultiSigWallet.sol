// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract MultiSigWallet {
    event Deposit(address indexed from, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(uint txId => mapping(address owner => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only Owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "Out of range");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "transaction already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of owners");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "owner already existed");

            owners.push(owner);
            isOwner[owner] = true;
        }
        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));

        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "transaction is not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function executeTransaction(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovedCount(_txId) >= required, "approved count is less than required");

        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "transaction failed");

        emit Execute(_txId);
    }

    function _getApprovedCount(uint _txId) private view returns(uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) count++;
        }
    }

    function txLen() external view returns(uint) {
        return transactions.length;
    }

    function getOwners() external view returns(address[] memory) {
        return owners;
    }
}