// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    uint256 public totalTips;

    mapping(address => uint256) public tipsBySupporter;
    address[] public supporters;

    event Tipped(address indexed from, uint256 amount, string message);
    event Withdrawn(address indexed to, uint256 amount);
    event RewardEligible(address indexed supporter);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Send a tip with optional message
    function sendTip(string calldata message) external payable {
        require(msg.value > 0, "Tip must be greater than 0");

        if (tipsBySupporter[msg.sender] == 0) {
            supporters.push(msg.sender);
        }

        tipsBySupporter[msg.sender] += msg.value;
        totalTips += msg.value;

        emit Tipped(msg.sender, msg.value, message);

        if (tipsBySupporter[msg.sender] >= 1 ether) {
            emit RewardEligible(msg.sender);
        }
    }

    // Withdraw funds to owner's wallet
    function withdrawTips() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No tips to withdraw");

        payable(owner).transfer(balance);
        emit Withdrawn(owner, balance);
    }

    // Get current balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get top tipper (demo purpose)
    function getTopTipper() external view returns (address topSupporter) {
        uint256 highest = 0;
        for (uint256 i = 0; i < supporters.length; i++) {
            if (tipsBySupporter[supporters[i]] > highest) {
                highest = tipsBySupporter[supporters[i]];
                topSupporter = supporters[i];
            }
        }
    }
}
