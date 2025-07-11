// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyWETH is ERC20 {
    constructor() ERC20("My Wrapped Ether", "MWETH") {}

    event Deposit(address indexed src, uint amount);
    event Withdraw(address indexed dst, uint amount);

    function deposit() public payable {
        _mint(_msgSender(), msg.value);
        emit Deposit(_msgSender(), msg.value);
    }

    function withdraw(uint amount) external {
        _burn(_msgSender(), amount);
        payable(_msgSender()).transfer(amount);
        emit Withdraw(_msgSender(), amount);
    }

    function totalSupply() public view override  returns (uint256) {
        return address(this).balance;
    }

    fallback() external payable {
        deposit();
    }
    receive() external payable {
        deposit();
    }
}
