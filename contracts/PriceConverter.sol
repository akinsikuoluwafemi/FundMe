// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // priceFeed is of type AggregatorV3Interface, then we put in the address of the aggregator, eth to usd, the chainlink address
        (, int256 answer,,,) = priceFeed.latestRoundData(); //we only need only the answer
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 sepolia chainlink pricefeed address eth/usd
        // ETH in terms of USD
        // ABI
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        return uint256(answer * 1e10); //we now multiply the answer by 10^10 because it returns to the power of 8, to match the wei value e10, means 10 decimal places
    }

  

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); //the result of calling getPrice() above;
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd; //returns theconversion in usd
    }
}
