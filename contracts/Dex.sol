// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./Wallet.sol";


enum Side{
    Buy,
    Sell
}


contract Dex is Wallet{

    using SafeMath for uint256;

    struct Order{
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
    }
    
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;


    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(
        Side _side,  
        bytes32 _ticker, 
        uint _amount, 
        uint _price) public view {
            if(_side == Side.Buy){
                require(balances[msg.sender][_ticker] >= _amount.mul(_price));
            }

            else if (_side == Side.Sell){
                require(balances[msg.sender][_ticker] >= _amount);
            }
    }

    
    


}