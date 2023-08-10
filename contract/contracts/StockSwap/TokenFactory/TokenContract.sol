// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenContract is ERC20 {
    address public owner;

    constructor(string memory name, string memory symbol, uint256 amount, address sender) ERC20(name, symbol) {
        owner = sender;
        _mint(owner, amount * 10 ** decimals());
    }
}