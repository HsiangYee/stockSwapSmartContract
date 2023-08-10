// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenFactory/TokenFactory.sol";

contract StockSwapMain {
    ITokenFactory tokenFactory;

    constructor(address _tokenFactoryAddress) {
        tokenFactory = ITokenFactory(_tokenFactoryAddress);
    }

    function createToken(string memory name, string memory symbol, uint256 amount) external {
        tokenFactory.createToken(name, symbol, amount);
    }
}
