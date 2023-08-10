// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PairContract is ERC20 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Swap(address indexed, address stableTokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    IERC20 public stableToken;
    IERC20 public token;
    uint256 public reserveStableToken;
    uint256 public reserveToken;

    constructor(address _token, string memory name, string memory symbol) ERC20(name, symbol) {
        stableToken = IERC20(0xDFa23CC08eEBaB9bD88177cDe0ea1F2Bd43BD874);
        token = IERC20(_token);
    }

    // 加入流動性
    function addLiquidity(uint256 stableToken_amount, uint256 token_amount) external {
        require(stableToken_amount > 0 && token_amount > 0, "Invalid amounts");

        uint256 amountStableToken = stableToken_amount;
        uint256 amountToken = token_amount;

        if (reserveStableToken != 0 && reserveToken != 0) {
            // 計算優化的 Token 數量
            uint256 amountTokenOptimal = quote(stableToken_amount);

            if (amountTokenOptimal <= token_amount) {
                amountToken = amountTokenOptimal;
            } else {
                // 計算優化的 StableToken 數量
                amountStableToken = quote(token_amount);
            }
        }

        _transferTokensAndAdjustReserves(stableToken, token, amountStableToken, amountToken);
        _mint(msg.sender, _liquidity(amountStableToken, amountToken));
    }

    // 移除流動性
    function removeLiquidity(uint256 liquidity) external {
        require(balanceOf(msg.sender) >= liquidity, "Insufficient LP tokens");

        // 計算流動性提供者的份額
        uint256 totalLiquidity = totalSupply();
        uint256 percentageShare = liquidity.mul(1e18).div(totalLiquidity);

        // 計算他們能夠獲得的代幣數量
        uint256 amountStableToken = reserveStableToken.mul(percentageShare).div(1e18);
        uint256 amountToken = reserveToken.mul(percentageShare).div(1e18);

        // 更新資金池的儲備
        reserveStableToken = reserveStableToken.sub(amountStableToken);
        reserveToken = reserveToken.sub(amountToken);

        // 轉移代幣
        stableToken.safeTransfer(msg.sender, amountStableToken);
        token.safeTransfer(msg.sender, amountToken);

        // 銷毀 LP 代幣
        _burn(msg.sender, liquidity);
    }


    // 購買代幣
    function buy(uint256 tokenAmount) external {
        require(tokenAmount > 0, "Token amount must be greater than 0");

        // 計算需要的 StableToken 數量
        uint256 stableTokenAmount = getAmountsIn(tokenAmount);

        // 從買家處收取 StableToken
        stableToken.safeTransferFrom(msg.sender, address(this), stableTokenAmount);
        reserveStableToken = reserveStableToken.add(stableTokenAmount);

        // 將 Token 轉移到買家的賬戶
        token.safeTransfer(msg.sender, tokenAmount);
        reserveToken = reserveToken.sub(tokenAmount);

        emit Swap(msg.sender, address(stableToken), address(token), stableTokenAmount, tokenAmount);
    }

    // 出售代幣
    function sell(uint256 tokenAmount) external {
        _swap(token, stableToken, tokenAmount);
    }

    // 報價函數
    function quote(uint256 amountToken) public view returns (uint256) {
        require(amountToken > 0, "Insufficient input amount");
        require(reserveStableToken > 0 && reserveToken > 0, "Insufficient liquidity");
        return amountToken.mul(reserveStableToken).div(reserveToken);
    }

    // 取得資金池餘額
    function getReserves() public view returns (uint256, uint256) {
        return (reserveStableToken, reserveToken);
    }

    // 獲取購買指定數量的 Token 所需的 StableToken 數量
    function getAmountsIn(uint256 tokenAmount) public view returns (uint256) {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(reserveStableToken > 0 && reserveToken > 0, "Insufficient liquidity");

        uint256 numerator = tokenAmount.mul(reserveStableToken);
        uint256 denominator = reserveToken.sub(tokenAmount);
        uint256 requiredStableToken = numerator.div(denominator);

        // 考慮到手續費，對 requiredStableToken 進行調整
        uint256 fee = requiredStableToken.div(1000).mul(3);  // Assuming 0.3% fee
        requiredStableToken = requiredStableToken.add(fee);

        return requiredStableToken;
    }

    // 獲取賣出指定數量的 Token 可以獲得的 StableToken 數量
    function getAmountsOut(uint256 amountIn) public view returns (uint256 amountOut) {
        require(amountIn > 0, "Insufficient input amount");
        require(reserveStableToken > 0 && reserveToken > 0, "Insufficient liquidity");

        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveStableToken);
        uint256 denominator = reserveToken.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getPoolShare(address provider) public view returns (uint256) {
        // 流動性提供者的 LP 代幣餘額
        uint256 providerBalance = balanceOf(provider);

        // LP 代幣的總供應量
        uint256 totalSupply = totalSupply();

        // 流動性提供者的比例
        uint256 poolShare = providerBalance.mul(1e18).div(totalSupply);

        return poolShare; // 返回的是基於 1e18 的百分比
    }

    // Helper functions
    function _swap(IERC20 fromToken, IERC20 toToken, uint256 amountIn) private {
        require(amountIn > 0, "Invalid input amount");

        uint256 amountOut = _calculateOutputAmount(amountIn);

        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        toToken.safeTransfer(msg.sender, amountOut);

        if (address(fromToken) == address(stableToken)) {
            reserveStableToken = reserveStableToken.add(amountIn);
            reserveToken = reserveToken.sub(amountOut);
        } else {
            reserveToken = reserveToken.add(amountIn);
            reserveStableToken = reserveStableToken.sub(amountOut);
        }

        emit Swap(msg.sender, address(fromToken), address(toToken), amountIn, amountOut);
    }

    function _transferTokensAndAdjustReserves(IERC20 fromToken, IERC20 toToken, uint256 amountFrom, uint256 amountTo) private {
        fromToken.safeTransferFrom(msg.sender, address(this), amountFrom);
        toToken.safeTransferFrom(msg.sender, address(this), amountTo);

        reserveStableToken = reserveStableToken.add(amountFrom);
        reserveToken = reserveToken.add(amountTo);
    }

    function _calculateReserveAmount(uint256 total, uint256 liquidity, uint256 reserve) private pure returns (uint256) {
        return reserve.mul(liquidity).div(total);
    }

    function _liquidity(uint256 amountStableToken, uint256 amountToken) private pure returns (uint256) {
        return sqrt(amountStableToken.mul(amountToken));
    }

    function _calculateOutputAmount(uint256 amountIn) private view returns (uint256) {
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveToken);
        uint256 denominator = reserveStableToken.mul(1000).add(amountInWithFee);

        return numerator.div(denominator);
    }

    // 開平方函數
    function sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
