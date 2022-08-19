// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SpiderX {

    mapping (address => uint) public users;
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() public payable {
        require(msg.value > 0, "deposit cannot be zero!");
        users[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        require(users[msg.sender] >= amount, "insufficient funds");
        require(payable(msg.sender).send(amount));
        users[msg.sender] -= amount;
    }

    function fullBalance() public view returns (uint balance){
        balance = address(this).balance;
    }
}
