// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SwapStock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Pair {
        IERC20 token1;
        IERC20 token2;
        uint256 reserve1;
        uint256 reserve2;
        uint256 K; // Constant K value for this pair
    }

    mapping(address => mapping(address => Pair)) public pairs;
    address[][] public activePairs;

    event AddLiquidity(address indexed provider, address indexed token1, address indexed token2, uint256 amount1, uint256 amount2);
    event Swap(address indexed user, address indexed inputToken, address indexed outputToken, uint256 inputAmount, uint256 outputAmount);

    function addLiquidity(address sender, address token1, address token2, uint256 amount1, uint256 amount2) external {
        IERC20(token1).safeTransferFrom(sender, address(this), amount1);
        IERC20(token2).safeTransferFrom(sender, address(this), amount2);

        pairs[token1][token2].token1 = IERC20(token1);
        pairs[token1][token2].token2 = IERC20(token2);
        pairs[token1][token2].reserve1 = pairs[token1][token2].reserve1.add(amount1);
        pairs[token1][token2].reserve2 = pairs[token1][token2].reserve2.add(amount2);

        if (pairs[token1][token2].K == 0) {
            pairs[token1][token2].K = pairs[token1][token2].reserve1.mul(pairs[token1][token2].reserve2);
            activePairs.push([token1, token2]);
        }

        emit AddLiquidity(sender, token1, token2, amount1, amount2);
    }

    function swap(address inputToken, address outputToken, uint256 inputAmount) external {
        require(pairs[inputToken][outputToken].reserve1.mul(pairs[inputToken][outputToken].reserve2) >= pairs[inputToken][outputToken].K, "K value constraint not satisfied");

        IERC20(inputToken).safeTransferFrom(msg.sender, address(this), inputAmount);

        uint256 outputAmount = calculateOutputAmount(inputToken, outputToken, inputAmount);
        require(outputAmount <= pairs[inputToken][outputToken].reserve2, "Insufficient liquidity");

        IERC20(outputToken).safeTransfer(msg.sender, outputAmount);

        pairs[inputToken][outputToken].reserve1 = pairs[inputToken][outputToken].reserve1.add(inputAmount);
        pairs[inputToken][outputToken].reserve2 = pairs[inputToken][outputToken].reserve2.sub(outputAmount);

        emit Swap(msg.sender, inputToken, outputToken, inputAmount, outputAmount);
    }


    function calculateOutputAmount(address inputToken, address outputToken, uint256 inputAmount) public view returns (uint256) {
        uint256 inputReserve = pairs[inputToken][outputToken].reserve1;
        uint256 outputReserve = pairs[inputToken][outputToken].reserve2;

        uint256 numerator = inputAmount.mul(outputReserve);
        uint256 denominator = inputReserve.add(inputAmount);

        return numerator.div(denominator);
    }

    function calculateInputAmount2(address inputToken, address outputToken, uint256 outputAmount) public view returns (uint256) {
        uint256 inputReserve = pairs[inputToken][outputToken].reserve1;
        uint256 outputReserve = pairs[inputToken][outputToken].reserve2;
        
        require(outputReserve > outputAmount, "Insufficient liquidity");

        uint256 numerator = inputReserve.mul(outputAmount);
        uint256 denominator = outputReserve.sub(outputAmount);

        return numerator.div(denominator).add(1);
    }


    function getActivePairs() external view returns (address[][] memory) {
        return activePairs;
    }
}
