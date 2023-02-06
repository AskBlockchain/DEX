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
    it("Should throw an error when creating a buy market order withut adequate ETH balance", async () => {
        let dex = await Dex.deployed()
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"))

        assert.equal(balance.toNumber(), 0, "Initial ETH balance is not 0")

        await truffleAssert.reverts(
            dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
        )
    })

    //Market orders can be submitted even if the orderbook is empty
    it("Market orders can be submitted even if the orderbook is empty", async () =>{
        let dex = await Dex.deployed()
        await dex.depositEth({value: 10000})

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8,("LINk"), 0) //Get buy side orderbook
        assert(orderbook.length == 0, "Buy side )rderbook length is not 0")

        await truffleAssert.passes(
            dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
        )
    })

    //Market orders should be filled until the order book is empty or the market order is 100% filled 
    it("Market orders should not fill more limit orders than the market order amount", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINk"), 1) //Get sell side orderbook
        assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test")

        await dex.addToken(web3.utils.fromUtf8("LINK"), link.address)

        //Send LINK tokens to accounts 1, 2, 3 from Account 0
        await link.transfer(account[1], 50)
        await link.transfer(account[2], 50)
        await link.transfer(account[3], 50)

        //Approve DEX for accounts 1, 2, 3
        await link.approve(dex.address, 50, {from: accounts[1]})
        await link.approve(dex.address, 50, {from: accounts[2]})
        await link.approve(dex.address, 50, {from: accounts[3]})

        //Deposit LINK into DEX for accounts 1, 2, 3
        await dex.deposit(50, web3.utils.fromUtf8("LINK"), {from: accounts[1]})
        await dex.deposit(50, web3.utils.fromUtf8("LINK"), {from: accounts[2]})
        await dex.deposit(50, web3.utils.fromUtf8("LINK"), {from: accounts[3]})

        //Fill up the sell orderbook
        await dex.createLimitOrder(1, web3.utils,fromUtf8("LINK"), 5, 300, {from: accounts[1]})
        await dex.createLimitOrder(1, web3.utils,fromUtf8("LINK"), 5, 400, {from: accounts[2]})
        await dex.createLimitOrder(1, web3.utils,fromUtf8("LINK"), 5, 500, {from: accounts[3]})

        //Create market order that should fill 2/3 orders in the book
        await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10) 

        orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook
        assert(orderbook.length == 1, "Sell side Orderbook should only have 1 order left")
        assert(orderbook[0].filled == 0, "Sell side order should have 0 filled")


        //Market orders should be filled until the order book is empty or the market order is 100% filled  
        it("Market orders should be filled until the orderbook is empty", async () => {
            let dex = await Dex.deployed()

            let orderbook = await dex.getOrderBook(web3.utils.from("LINK"), 1); //Get sell side orderbook
            assert(orderbook.length == 1, "Sell side Orderbook should have 1 order left")

            //Fill up the SELL order book again
            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 400, {from: accounts[1]})
            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 500, {from: accounts[2]})

            //check buyer LINK balance before LINK purchase
            let balanceBefore = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"))

            //Create market order that could fill more than entire orderbook (15 LINK)
            await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 50)

            //Check buyer LINK balance after LINK purchase
            let balanceAfter = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"))

            //Buyer should have 15 more LINk after, even though order was for 50
            assert.equal(balanceBefore + 15, balanceAfter)

        })

        //The eth balance of the BUYER should decrease with filled amount
        it("ETH balance of the BUYER should decrease when order is filled", async () => {
            let dex = await Dex.deployed()
            let link = await Link.deployed()

            await dex.depositEth({value: 10000})
            
            
            //SELLER Deposit LINK & Approves Dex
            await link.approve(dex.address, 500, {from: account[1]})
            //Create Limit Order
            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300, {from: accounts[1]})
            
            

            //Check buyer ETH balance before LINK Trade
            let balanceBefore = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"))
            //Create MARKET Order
            await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 1)
            //Check buyer ETH balance after Trade
            let balanceAfter = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"))

            //Buyer should have 10000ETH - 70ETH = 9930
            assert.equal(balanceBefore.toNumber() - 70, balanceAfter.toNumber())


        })

        //The token balances of the sellers should decrease with the filled amounts.
        it("The token balances of the Limit Order Sellers should decrease with the filled amounts", async () => {
            dex = await Dex.deployed()
            link = await Link.deployed()


            let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook
            assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test")


            //Seller Accounts[2] depoits link
            await link.approve(dex.address, 500, {from: account[2]})
            await dex.deposit(100, web3.utils.fromUtf8("LINK"), {from: accounts[2]})

            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300, {from: accounts[1]})
            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300, {from: accounts[2]})

            //Check sellers LINK balances before trade
            let account1BalanceBefore = await dex.balances(accounts[1], web3.utils.fromUtf8("LINK"))
            let account2BalanceBefore = await dex.balances(accounts[1], web3.utils.fromUtf8("LINK"))

            //Account[0] created market order to BUY up both SELL orders
            await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 2)

            //Check sellers LINK balances after trade
            let account1BalanceAfter = await dex.balances(accounts[1], web3.utils.fromUtf8("LINK"))
            let account2BalanceAfter = await dex.balances(accounts[2], web3.utils.fromUtf8("LINK"))

            assert.equal(account1BalanceBefore.toNumber() -1, account1BalanceAfter.toNumber())
            assert.equal(account2BalanceBefore.toNumber() -1, account2BalanceAfter.toNumber())         


        })

        //Filled limit orders should be removed from the orderbook
        it("Filled limit orders should be removed from the eorderbook", async () => {
            let dex = await Dex.deployed()
            let link = await Link.deployed()
            await dex.addToken(web3.utils.fromUtf8("LINK"), link.address)


            //Seller deposits LINK and creates a SELL LIMIT order for 1 LINK for 300 wei
            await link.approve(dex.address, 500)
            await dex.deposit(50, web3.utils.fromUtf8("LINK"))

            await dex.depositEth({value: 10000})

            let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook

            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300)
            await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 1)

            orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook
            assert(orderbook.length == 0, "Sell side Orderbook should be empty after trade")
        })
        
        //Partly filled limit orders should be modified to represent the filled/remaining amount
        it("Limit orders filled property should be set correctly after a trade", async () => {
            let dex = await Dex.deployed()

            let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook
            assert(orderbook.length == 0, "Sell side Orderbook should be empty at start of test")

            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {from: accounts[1]})
            await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 2)

            orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1) //Get sell side orderbook
            assert.equal(orderbook[0].filled, 2)
            assert.equal(orderbook[0].amount, 5)
        })

        //When creating a BUY MARKET Order, the buyer needs to have enough ETH for the trade
        it("Should throw an error when creating a BUY MARKET order without adequate ETH balance", async () => {
            let dex = await Dex.deployed()

            let balance = await dex.balances(accounts[4], web3.utils.fromUtf8("ETH"))
            assert.equal(balance.toNumber(), 0, "Initial ETH balance is not 0")
            await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {from: accounts[1]})

            await truffleAssert.reverts(
                dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 5, {from: accounts[4]})
            )
        })



    })


});

























