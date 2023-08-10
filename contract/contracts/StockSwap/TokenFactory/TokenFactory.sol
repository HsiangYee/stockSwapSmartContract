// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFactory {
    struct TokenDetail {
        address tokenAddress;
        string name;
        string symbol;
    }

    TokenDetail[] public tokens;
    mapping(address => TokenDetail) public tokenDetails;

    event TokenCreated(address tokenAddress, string name, string symbol);

    function createToken(string memory name, string memory symbol, uint256 amount) external {
        TokenContract newToken = new TokenContract(name, symbol, amount, msg.sender);
        TokenDetail memory newTokenDetail = TokenDetail({
            tokenAddress: address(newToken),
            name: name,
            symbol: symbol
        });

        tokens.push(newTokenDetail);
        tokenDetails[address(newToken)] = newTokenDetail;

        emit TokenCreated(address(newToken), name, symbol);
    }

    function getDeployedTokens() external view returns (TokenDetail[] memory) {
        return tokens;
    }

    function getTokenDetail(address _tokenAddress) external view returns (TokenDetail memory) {
        return tokenDetails[_tokenAddress];
    }
}