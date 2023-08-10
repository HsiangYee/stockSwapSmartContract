// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract v2330 is ERC20 {
    address public owner;

    constructor() ERC20("virtualStock1", "vStock1") {
        owner = msg.sender;
        _mint(owner, 25930380000 * 10 ** decimals());
    }
}

