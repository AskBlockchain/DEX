const Link = artifacts.require("Link");
const Wallet = artifacts.require("Wallet");


module.exports = async function (deployer) {
  await deployer.deploy(Link);
  let wallet = await Wallet.deployed();
  let link = await Link.deployed();
  await link.approve(wallet.address, 300);
  await wallet.addToken(web3.utils.fromUtf8("LINK"), link.address);
  //await wallet.deposit(100, web3.utils.fromUtf8("LINK"));  
 };

