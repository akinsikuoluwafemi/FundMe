// SPDX-License-Identifier: MIT
// pragma
pragma solidity ^0.8.9;

// imports
import "./PriceConverter.sol";

// errors
error FundMe__NotOwner();

/**
 * @title A contract for crowd funding
 * @author Femi Akinsiku
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] private s_funders;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOnwer {
        // require(msg.sender == owner, "Sender is not owner!");
        if(msg.sender != i_owner)  revert FundMe__NotOwner();  //another way of using revert instead of require
        _;
    }

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // receive () external payable {  //recieve will fire if you initiate a transaction without data
    //     fund();
    // }

    // fallback () external payable { //fallback will fire if you send a value to the contract. when data is sent along with the transaction
    //     fund();
    // }

    /**
 * @notice This function funds this contract
 * @dev This implements price feeds as our library
 */
    function fund() public payable {
        // instead of saying getConversionRate(msg.value), we can say this msg.value.getConversionRate()
        //msg.value is considered the first parameter in a library function
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough"); //make sure what the user sends is more than 1eth
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value; //to get the amount an address has funded, you keep adding the value to the previous amount
    }

    function withdraw ()  public onlyOnwer{
        // mapping through the funders array
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++ ){
            address funder = s_funders[funderIndex]; //a single funder (single address that has funded)
            s_addressToAmountFunded[funder] = 0; //you loop and set the value of that address to 0, after an address calls withraw method or a user widthraws
        }
        // reset the array, after the owner withdraws it
        s_funders = new address[](0); //an empty array with 0 objects in it.
        // actually withraw the funds
        // transfer
        // send
        // call

        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call (call returns 2 variables, we dont need the other one)
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}(""); //call function returns two variables, but we only need callSuccess
        require(callSuccess, "Call failed");
        // revert();
    }

    function cheaperWithdraw () public payable onlyOnwer {
        address[] memory funders = s_funders;

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
             s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
         (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}(""); //call function returns two variables, but we only need callSuccess
        require(callSuccess, "failed to withdraw");
    }

    function getOwner() public view returns(address){
        return i_owner;
    }

    function getFunder(uint256 index) public view returns(address) {
        return s_funders[index];
    }
    function getAddressToAmountFunded (address funder) public view returns (uint256){
        return s_addressToAmountFunded[funder];
    }
    function getPriceFeed () public view returns (AggregatorV3Interface){
        return s_priceFeed;
    }

}