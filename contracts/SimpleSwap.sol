// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// Constant Product Automated Market Maker
/// k = x * y
contract SimpleSwap is ERC20 {
    IERC20 public token0;
    IERC20 public token1;

    uint public reserve0;
    uint public reserve1;

    event Mint(address indexed target, uint amount0Desired, uint amount1Desired);
    event Burn(address indexed target, uint amount0, uint amount1);
    event Swap(
        address indexed sender, 
        uint amountIn, address tokenIn, 
        uint amountOut, address tokenOut
    );

    constructor(IERC20 token0_, IERC20 token1_) ERC20("SimpleSwap", "SS") {
        token0 = token0_;
        token1 = token1_;
    }

    function addLiquidity(uint amount0Desired, uint amount1Desired) external returns(uint liquidity) {
        token0.transferFrom(msg.sender, address(this), amount0Desired);
        token1.transferFrom(msg.sender, address(this), amount1Desired);
        
        uint _totalSupply = totalSupply();
        
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0Desired * amount1Desired);
        } else {
            liquidity = Math.min(amount0Desired * _totalSupply / reserve0, amount1Desired * _totalSupply / reserve1);
        }

        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");

        _mint(msg.sender, liquidity);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Mint(msg.sender, amount0Desired, amount1Desired);
    }

    function removeLiquidity(uint liquidity) external returns(uint amount0, uint amount1) {
        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        uint _totalSupply = totalSupply();

        amount0 = liquidity * balance0 / _totalSupply;
        amount1 = liquidity * balance1 / _totalSupply;

        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(msg.sender, liquidity);

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Burn(msg.sender, amount0, amount1);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns(uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY"); 
        
        amountOut = amountIn * reserveOut / (reserveIn + amountIn);
    }

    function swap(uint amountIn, IERC20 tokenIn, uint amountOutMin) external returns(uint amountOut, IERC20 tokenOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(tokenIn == token0 || tokenIn == token1, "INVALID_TOKEN");

        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this)); 

        if (tokenIn == token0) {
            amountOut = getAmountOut(amountIn, balance0, balance1);
            tokenOut = token1;

        } else {
            amountOut = getAmountOut(amountIn, balance1, balance0);
            tokenOut = token0;
        }

        require(amountOut >= amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(msg.sender, amountOut);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Swap(msg.sender, amountIn, address(tokenIn), amountOut, address(tokenOut));
    }
}
