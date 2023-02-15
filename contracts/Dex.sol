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
        uint filled;
    }

    uint public nextOrderId = 0;
    
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;
    

    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }


    function getTotalTokenAmountForSale(bytes32 ticker) view external returns (uint) {
    uint totalAmount = 0;
    // Get the array of Order structs for the specified ticker and the side "for sale"
    Order[] memory orders = orderBook[ticker][uint(Side.Sell)];
    // Iterate over the array and add up the amounts of each Order struct
    for (uint i = 0; i < orders.length; i++) {
        totalAmount += orders[i].amount;
    }
    // Return the total amount
    return totalAmount;
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

        function createMarketOrder(Side side, bytes32 ticker, uint amount) public {
            if(side == Side.Sell){
                require(balances[msg.sender][ticker] >= amount, "Insuffient balance");
            }
            uint orderBookSide;
            if(side == Side.Buy){
                orderBookSide = 1;
                } 
                else{orderBookSide = 0;
                }

                Order[] storage orders = orderBook[ticker][orderBookSide];

                uint totalFilled; //How much has been Filled veriable 

                for(uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
                    //How much we can fill from order[i]
                    uint leftToFill = amount.sub(totalFilled); //Market Orders that hasn't been filled
                    uint availableToFill = orders[i].amount.sub(orders[i].filled); //Sell Orders that hasn't been filled
                    uint filled = 0; //The excess BUY or SELL orders
                    if(availableToFill > leftToFill){
                        filled = leftToFill; //Excess Market BUY orders
                    }
                    else{ //availableToFill <= leftToFill
                        filled = availableToFill; //Excess/Existing SELL orders
                    }

                    //After each loop we update the totalFilled veriable
                    totalFilled = totalFilled.add(filled);

                    
                    
                    
                    //Execute the trade & shift balances between buyer/seller
                    //Verify that the buyer has enough ETH to cover the purchase (require)
                }

                //Loop through the orderbook and remove 100% filled orders
        }
    
    





    
}

