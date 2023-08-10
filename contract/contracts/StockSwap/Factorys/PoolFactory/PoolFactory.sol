// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PairContract.sol";

contract PoolFactory {
    // key是代幣的地址，value是該代幣對應的Pair合約地址
    mapping(address => address) public getPair;
    address[] public allPairs;

    event LPTokenCreated(address indexed lpToken, string name, string symbol);

    // 創建流動池
    function createPair(address token, string memory name, string memory symbol) external {
        require(getPair[token] == address(0), "pair is exist"); // 防止重複創建交易對

        PairContract newPair = new PairContract(token, name, symbol);
        
        getPair[token] = address(newPair);
        allPairs.push(address(newPair));
        emit LPTokenCreated(address(newPair), name, symbol);
    }

    // 確認流動池是否存在
    function checkPairExists(address token) external view returns (bool, address) {
        address pairAddress = getPair[token];
        bool pairExists = pairAddress != address(0);
        return (pairExists, pairAddress);
    }

    // 取得所有流動池
    function getAllPairs() external view returns (address[] memory) {
        return allPairs;
    }
}
