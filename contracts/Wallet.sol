// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/utils/TokenTimelock.sol)

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract wallet {

    using SafeMath for uint256;

    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;
    mapping(address => mapping(bytes32 => uint256)) public balances;
    

    function addToken(bytes32 ticker, address tokenAddress) external {
        tokenMapping[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) external {

    }

     function withdraw(uint amount, bytes32 ticker) external {
        require(tokenMapping[ticker].tokenAddress != address(0));
        require(balances[msg.sender][ticker] >= amount, "Insufficient Balance");
        
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount);
    }

    
}