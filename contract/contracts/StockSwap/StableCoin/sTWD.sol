// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TWDs is ERC20 {
    address public owner;

    constructor() ERC20("TaiwanStableCoin", "TWDs") {
        owner = msg.sender;
        _mint(owner, 1000000000 * 10 ** decimals());
    }
}