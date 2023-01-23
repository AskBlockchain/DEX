// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 ^0.8.0;
pragma experimental ABIEncoderV2;
import "./Wallet.sol";

contract Dex is Wallet{

    using SafeMath for uint256;

    enum Side{
    Buy,
    Sell
    }

    struct Order{
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
    }

    uint public nextOrderId = 0;
    
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;


    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(
         Side _side,  
         bytes32 _ticker, 
         uint _amount, 
         uint _price) public {
             if(_side == Side.Buy){
                 require(balances[msg.sender]["ETH"] >= _amount.mul(_price));
                }

                else if (_side == Side.Sell){
                require(balances[msg.sender][_ticker] >= _amount);
            }

            Order[] storage orders = orderBook[_ticker][uint(_side)];

            orders.push(
            Order(nextOrderId, msg.sender, _side, _ticker, _amount, _price)
            );

            //Bubble sort
            if(_side == Side.Buy){


            }
            else if(_side == Side.Sell){

            }

        }
    
}

