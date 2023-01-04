// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.18;
pragma experimental ABIEncoderV2;
import "./Wallet.sol";


enum Side{
    Buy,
    Sell
}


contract Dex is Wallet{

    struct Order{
        uint id;
        address trader;
        bool buyOrder;
        uint amount;
        uint price;
    }
    
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;


    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }

    
    


}