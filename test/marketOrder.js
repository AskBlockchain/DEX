const truffleAssert = require('truffle-assertions');
const Dex = artifacts.require("Dex");
const Link = artifacts.require("Link");

contract('Dex', async (accounts) => {
  
    
    //When creating a SELL market order, the seller needs to have enough tokens for the trade  
    it("Should throw an error when creating a SELL MARKET ORDER without adequate token balance", async () => {
        let dex = await Dex.deployed()
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"))
        assert.equal(balance.toNumber(), 0, "Initial LINK balance is not 0")
        await truffleAssert.reverts(
            dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), 10)
        )
    })
  
    //When creating a BUY market order, the buyer needs to have enough ETH for the trade
    it("The Buyer should have enough ETH when creating a BUY MARKET ORDER", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await truffleAssert.reverts(
            dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
        )
        await dex.depositEth({value: 10})
        await truffleAssert.passes(
            dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
        )

    })

    //Market orders can be submitted even if the orderbook is empty
    it("Market orders can be submitted even if the orderbook is empty", async () =>{
        let dex = await Dex.deployed()
        await dex.depositEth({value: 5000})

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8,("LINk"), 0)
        assert(orderbook.length == 0, "Buy side )rderbook length is not 0")

        await truffleAssert.passes(
            dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
        )
    })

    //Market orders should be filled until the order book is empty or the market order is 100% filled 
    it("Market orders should not fill more limit orders than the market order amount", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8,("LINk"), 1)

    })


});

















//Market orders should be filled until the order book is empty or the market order is 100% filled  
//The eth balance of the BUYER should decrease with filled amount
//The token balances of the sellers should decrease with the filled amounts.
//Filled limit orders shoud be removed for the orderbook



// it("should fail when creating a SELL market order and the seller doesn't have enough tokens", async () => {
//     let sellAmount = initialSellerBalance + 1;
//     await truffleAssert.reverts(
//         dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), sellAmount, 1),
//         'Not enough tokens'
//     );
// });

// it("should success when creating a SELL market order and the seller has enough tokens", async () => {
//     let sellAmount = initialSellerBalance;
//     await link.approve(dex.address, 500);
//     await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]});
//     await dex.deposit(10, web3.utils.fromUtf8("LINK"));

//     await truffleAssert.passes(
//         dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), sellAmount, 1)
//     );
// });





