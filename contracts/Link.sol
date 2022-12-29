//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Link is ERC20{
    constructor() ERC20("ChainLink", "LINK") {
        _mint(msg.sender, 5000);
    }
}