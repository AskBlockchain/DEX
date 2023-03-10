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
            orders.push(Order(nextOrderId, msg.sender, side, ticker, amount, price, 0));

            //Bubble Sort
            uint i; //i set and equal to 0
            uint orderlist = orders.length; //number of orders in the order[] array
            if(orderlist > 0 ){
                i = orderlist - 1;
                }   
                else {
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

            uint orderBookSide; //Keep track of the Buy or Sell Side we need
            //When creating a Market Order, we need to get the opposite trades Eg. if the Order is Buy then we get all the Sell orders
            if(side == Side.Buy){
                orderBookSide = 1;
                } 
                else{orderBookSide = 0;
                }

                Order[] storage orders = orderBook[ticker][orderBookSide]; //Creating a local Array to store type of token and Side 

                uint totalFilled = 0; //Track how much Market Orders has been Filled veriable 

                //We loop through all orders in the "orders Array" until the end OR "totalFilled" has been filled
                //The Loop continues as log as both conditions a True. The Loop exits when we reach the end of the list OR we fill all the orders
                for(uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
                    
                    uint leftToFill = amount.sub(totalFilled); //Market Orders that hasn't been filled with each loop (to be filled)
                    uint availableToFill = orders[i].amount.sub(orders[i].filled); //Sell Orders that hasn't been filled (available)
                    uint filled = 0; //The excess BUY or SELL orders
                    if(availableToFill > leftToFill){
                        filled = leftToFill; //If available orders are greater, it means all orders (Buy or Sell) HAVE BEEN filled                   
                    }
                    
                    else{ //Alternativly we HAVE NOT filled all our orders becuase there is no available orders
                        filled = availableToFill; 
                    }
                

                    totalFilled = totalFilled.add(filled);
                    //This line updates the "totalFilled" variable to include the amount filled for the current order 
                    //(represented by the "filled" variable). 
                    //The ".add()" function is used to add the value of "filled" to the current value of "totalFilled".

                    orders[i].filled = orders[i].filled.add(filled); //Current filled = Current filled + (filled on this iteration)
                    //This line updates the "filled" variable of the current order in the iteration 
                    //(represented by "orders[i]") to include the amount filled for the current order 
                    //(represented by the "filled" variable).
                    
                    uint cost = filled.mul(orders[i].price);
                    //This line calculates the cost of the filled amount for the current order, by multiplying the amount filled 
                    //(represented by the "filled" variable) by the price of the order (represented by the "price" variable of the current order).


                    //Execute the trade & shift balances between buyer/seller
                    if(side == Side.Buy){
                    //Verify that the buyer has enough ETH to cover the purchase (require)
                    require(balances[msg.sender]["ETH"] >= cost);
                        //msg.sender is Buyer
                        //Transfer ETH from Buyer to Seller
                        balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost); //Current value = Current value - (cost)
                        //Transfer Tokens from Seller to Buyer
                        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled); //Current "ticker" balance = Current balance + (filled)

                        //Add ETH from Buyer(msg.sender) to (Order.trader) 
                        balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].add(cost);
                        //Subtract Tokens(filled) from (Order.trader)
                        balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled);
                    }
                        

                    else if(side == Side.Sell){
                        //msg.sender is Seller
                        //Transfer ETH from Buyer to Seller
                        balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].add(cost); //Current value = Current value - (cost)
                        //Transfer Tokens from Seller to Buyer
                        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled); //Current "ticker" balance = Current balance + (filled)

                        //Add ETH from Buyer(msg.sender) to (Order.trader) 
                        balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].sub(cost);
                        //Subtract Tokens(filled) from (Order.trader)
                        balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled);
                       
                    }
                    
                }

                //Loop through the orderbook and remove 100% filled orders
                while(orders.length > 0 && orders[0].filled == orders[0].amount){
                //Remove the top element in the orders array by overwriting evey element
                //with the nextelement in the order list
                    for(uint i = 0; i < orders.length - 1; i++){
                    orders[i] = orders[i + 1];
                    }
                    orders.pop();
                }                 
                    
                    
        }
}                
        
    
    





    


