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

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {
             if(side == Side.Buy){
                 require(balances[msg.sender]["ETH"] >= amount.mul(price));
                }

                else if(side == Side.Sell){
                require(balances[msg.sender][ticker] >= amount);
            }

            Order[] storage orders = orderBook[ticker][uint(side)];
            orders.push(Order(nextOrderId, msg.sender, side, ticker, amount, price));

            //Bubble Sort
            uint i; //i set and equal to 0
            uint orderlist = orders.length; //number of orders in the order[] array
            if(orderlist > 0 ){
                i = orderlist - 1;
                }   else {
                i = 0;
                }

                
            if(side == Side.Buy){
                //A Do-While loop checks if orders[] is already sorted
                while(i > 0){
                    if(orders[i -1].price > orders[i].price) {
                        break;
                    }
                    //Sort orders[] from Highest to Lowest
                    Order memory orderToMove = orders[i-1]; //Create a variable of type Order (like uint) to store orders[index - 1] in memory
                    orders[i-1] = orders[i]; //Change the value of orders[index-1] to order[index]
                    orders[i] = orderToMove; //Now change the value of order[i] to order[i-1] via variable orderToMove
                    i--; //After the line above i is now set to the last item in the array. Use i-- to go back one place
                }

            }

            
            else if (side == Side.Sell) {
                //A Do-While loop checks if orders[] is already sorted
                while(i > 0){
                    if(orders[i -1].price < orders[i].price) {
                        break;
                    }
                    //Sort orders[] from Lowest to Highest 
                    Order memory orderToMove = orders[i-1]; //Create a variable of type Order (like uint) to store orders[index - 1] in memory
                    orders[i-1] = orders[i]; //Change the value of orders[index-1] to order[index]
                    orders[i] = orderToMove; //Now change the value of order[i] to order[i-1] via variable orderToMove
                    i--; //After the line above i is now set to the last item in the array. Use i-- to go back one place
                }  

            }      
            
            nextOrderId++;              
        }
    
}

