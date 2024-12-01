// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tipping {
    mapping(string => uint256) public tips;
    address public owner;
    uint256 private total_stored;
    uint256 private constant MIN_TIP_AMOUNT = 0.0001 ether;

    constructor() {
        owner = msg.sender;
    }

        // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function viewRevenue() public onlyOwner view returns (uint256){
          return address(this).balance - total_stored;
    }

    function tip(string memory username) public payable {
        // Validate tip amount
        require(msg.value >= MIN_TIP_AMOUNT, "Tip amount must be greater than 0.001 ether");

        // Calculate platform fee (1%)
        uint256 platformFee = msg.value / 100;

        // Add tip amount to user balance
        tips[username] += msg.value - platformFee;

        total_stored += tips[username];
    }

    function withdraw(string memory username, address reciver) public onlyOwner {
        // Check if user has any accumulated tips
        uint256 userTips = tips[username];
        require(userTips != 0, "No tips available to withdraw");

        // Reset user's balance
        tips[username] = 0;

        // Transfer withdrawal amount to user's wallet address
        payable(reciver).transfer(userTips);
    }

    function ammountOfTip(string memory username) public view returns (uint256){
        return tips[username];
    }

    function claimRevenue() public onlyOwner {
        payable(owner).transfer(address(this).balance - total_stored);
    }
}