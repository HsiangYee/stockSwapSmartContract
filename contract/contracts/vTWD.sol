// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract vTWD is ERC20 {
    address public owner;

    constructor() ERC20("VirtualTaiwanDollar", "vTWD") {
        owner = msg.sender;
        _mint(owner, 1000000000 * 10 ** decimals());
    }
}