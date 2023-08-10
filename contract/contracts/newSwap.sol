// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SwapStock is ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TokenPair {
        IERC20 token0;
        IERC20 token1;
        uint256 reserve0;
        uint256 reserve1;
    }

    mapping(address => mapping(address => TokenPair)) public pairs;
    event Swap(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor() ERC20("SwapStock LP Token", "SSLP") {}

    // Function to create a new liquidity pool
    function createPool(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        // Check if the pool already exists
        require(pairs[tokenA][tokenB].token0 == IERC20(address(0)) && pairs[tokenA][tokenB].token1 == IERC20(address(0)), "POOL_ALREADY_EXISTS");

        // Transfer the tokens from the user to this contract
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Update the token pair in the mapping
        pairs[tokenA][tokenB] = TokenPair({
            token0: IERC20(tokenA),
            token1: IERC20(tokenB),
            reserve0: amountA,
            reserve1: amountB
        });

        // Calculate and mint the LP tokens
        uint256 liquidity = sqrt(amountA.mul(amountB));
        _mint(msg.sender, liquidity);
    }

    // Function to add liquidity to an existing pool
    function addLiquidity(address tokenA, address tokenB, uint256 amountA_desired, uint256 amountB_desired) external {
        // Check if the pool exists
        require(pairs[tokenA][tokenB].token0 != IERC20(address(0)) && pairs[tokenA][tokenB].token1 != IERC20(address(0)), "POOL_DOES_NOT_EXIST");

        TokenPair storage pair = pairs[tokenA][tokenB];
        uint256 amountA;
        uint256 amountB;

        uint256 amountBOptimal = quote(amountA_desired, pair.reserve0, pair.reserve1);
        if (amountBOptimal <= amountB_desired) {
            require(amountBOptimal >= pair.reserve1, "INSUFFICIENT_B_AMOUNT");
            amountA = amountA_desired;
            amountB = amountBOptimal;
        } else {
            uint256 amountAOptimal = quote(amountB_desired, pair.reserve1, pair.reserve0);
            assert(amountAOptimal <= amountA_desired);
            amountA = amountAOptimal;
            amountB = amountB_desired;
        }

        // Transfer the tokens from the user to this contract
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Update the token pair in the mapping
        pair.reserve0 = pair.reserve0.add(amountA);
        pair.reserve1 = pair.reserve1.add(amountB);

        // Calculate and mint the LP tokens
        uint256 liquidity = sqrt(amountA.mul(amountB));
        _mint(msg.sender, liquidity);
    }

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity) external {
        require(balanceOf(msg.sender) >= liquidity, "Not enough LP tokens");

        TokenPair storage pair = pairs[tokenA][tokenB];
        uint256 totalLiquidity = totalSupply();

        uint256 amountA = pair.reserve0.mul(liquidity).div(totalLiquidity);
        uint256 amountB = pair.reserve1.mul(liquidity).div(totalLiquidity);

        pair.reserve0 = pair.reserve0.sub(amountA);
        pair.reserve1 = pair.reserve1.sub(amountB);

        IERC20(tokenA).safeTransfer(msg.sender, amountA);
        IERC20(tokenB).safeTransfer(msg.sender, amountB);

        _burn(msg.sender, liquidity);
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn) external {
        TokenPair storage pair = pairs[tokenIn][tokenOut];

        require(tokenIn == address(pair.token0) || tokenIn == address(pair.token1), "Invalid input token");
        require(tokenOut == address(pair.token0) || tokenOut == address(pair.token1), "Invalid output token");
        require(tokenIn != tokenOut, "Input and output tokens must be different");

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        uint256 fee = amountIn.mul(3).div(1000);  // 0.3% fee
        uint256 amountInAfterFee = amountIn.sub(fee);

        uint256 amountOut = calculateOutputAmount(pair, amountInAfterFee);
        require(pair.reserve1 >= amountOut, "Insufficient output reserve");

        pair.reserve0 = pair.reserve0.add(amountInAfterFee);
        pair.reserve1 = pair.reserve1.sub(amountOut);

        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    function calculateOutputAmount(TokenPair storage pair, uint256 amountIn) internal view returns (uint256) {
        uint256 fee = amountIn.mul(3).div(1000);  // 0.3% fee
        uint256 amountInAfterFee = amountIn.sub(fee);
        uint256 amountInWithFee = amountInAfterFee.mul(1000);
        uint256 numerator = amountInWithFee.mul(pair.reserve1);
        uint256 denominator = pair.reserve0.mul(1000).add(amountInWithFee);

        return numerator.div(denominator);
    }

    function getPoolInfo(address tokenA, address tokenB) public view returns (uint256, uint256, uint256) {
        TokenPair storage pair = pairs[tokenA][tokenB];
        uint256 reserveA = pair.reserve0;
        uint256 reserveB = pair.reserve1;
        uint256 price = reserveA.mul(1e18).div(reserveB);
        return (reserveA, reserveB, price);
    }

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256) {
        require(amountA > 0, "INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "INSUFFICIENT_LIQUIDITY");
        return amountA.mul(reserveB) / reserveA;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x.add(1)).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = (x.div(z).add(z)).div(2);
        }
    }
}
