// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // msg.value is in wei, 1 eth is 1e18 wei
        require(msg.value.getConversionRate() >= minimunUsd, "cannot send less than 5$ of ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset the funders array
        funders = new address[](0);

        /*
        The function call will look like this when is called another method
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}(anotherMethod);
        but here we're not calling another method so we can use
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        */
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call method failed"); 
    }

    modifier onlyOwner() {
        // first check the sender, after (with _) do all your things.
        // require(msg.sender == i_owner, "Sender is not the owner!");
        if(msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    // What happens if someone send ETH to this contract without calling the fund() method?
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}