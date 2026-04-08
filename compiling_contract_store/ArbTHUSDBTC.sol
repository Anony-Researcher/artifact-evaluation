// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

//import "hardhat/console.sol";


interface UniswapReserve {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}

interface ERC20Like {
    function approve(address spender, uint value) external returns(bool);
    function transfer(address to, uint value) external returns(bool);
    function balanceOf(address a) external view returns(uint);
}

interface WethLike is ERC20Like {
    function deposit() external payable;
}

interface CurveLike {
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint);    
}


interface BAMMLike {
    function swap(uint lusdAmount, uint minEthReturn, address payable dest) external returns(uint);
}

contract ArbTHUSDBTC {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant LUSD = 0xCFC5bD99915aAa815401C5a41A927aB7a38d29cf;    
    address constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant TBTC = 0x18084fbA666a33d37592fA2633fD49a74DD93a88;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;    

    UniswapReserve constant USDCBTC = UniswapReserve(0x4585FE77225b41b697C938B018E2Ac67Ac5a20c0);
    UniswapReserve constant USDCETH = UniswapReserve(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

    uint160 constant MIN_SQRT_RATIO = 4295128739;
    uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;    
    CurveLike constant CURV = CurveLike(0x212a60171E22988492B7C38a1A3553c60F1892BE);
    CurveLike constant CURV_WBTC_TBTC = CurveLike(0xB7ECB2AA52AA64a717180E030241bC75Cd946726);

    constructor() public {
        ERC20Like(USDC).approve(address(CURV), uint(-1));
        ERC20Like(TBTC).approve(address(CURV_WBTC_TBTC), uint(-1));             
    }

    function approve(address bamm) external {
        ERC20Like(LUSD).approve(address(bamm), uint(-1));
    }

    function swap(uint btcQty, address bamm, address profitReceiver) external payable returns(uint) {
        //console.log("doing swap");
        bytes memory data = abi.encode(bamm);
        // swap btc to eth
        USDCBTC.swap(address(this), true, int256(btcQty), MIN_SQRT_RATIO + 1, data);

        uint profit = ERC20Like(WBTC).balanceOf(address(this));
        if(profit > 0) ERC20Like(WBTC).transfer(profitReceiver, profit);

        return profit;
     }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        if(msg.sender == address(USDCETH)) {
            //console.log("eth swap");
            //console.log(uint(-1 * amount0Delta));
            //console.log(uint(amount1Delta));
            // send weth
            //console.log(ERC20Like(WETH).balanceOf(address(this)));
            ERC20Like(WETH).transfer(msg.sender, uint(amount1Delta));
            //console.log("eth was sent");
            return;
        }
        else {
            //console.log("wbtc swap");
            //console.log(uint(amount0Delta));
            //console.log(uint(-1 * amount1Delta));            
            require(msg.sender == address(USDCBTC), "must be uniswap WBTC reserve");
        }

        (address bamm) = abi.decode(data, (address));

        // swap ETH to USDC
        uint msgValue = address(this).balance;
        uint ethAmount = uint(-1 * amount1Delta) + msgValue;
        if(msgValue > 0) {
            //console.log("deposit auxilary eth");
            WethLike(WETH).deposit{value: uint(ethAmount)}();
        }

        // do simple swap without callbacks
        //console.log("swap eth");
        (int returnedUSDC, ) = USDCETH.swap(address(this), false, int256(ethAmount), MAX_SQRT_RATIO - 1, bytes(""));


        uint USDCAmount = uint(-1 * returnedUSDC);
        //console.log("usdc amount", USDCAmount);
        //console.log("swap usdc to lusd");
        uint LUSDReturn = swapUSDCToLUSD(USDCAmount);
        //console.log("LUSDReturn amount", LUSDReturn);

        //console.log("swap with bamm");
        uint tbtcRetAmount = BAMMLike(bamm).swap(LUSDReturn, 1, address(this));

        //console.log("bamm return", tbtcRetAmount);

        //console.log("swap tbtc to wbtc");
        uint wbtcRetVal = CURV_WBTC_TBTC.exchange(1, 0, tbtcRetAmount, 1);
        //console.log("wbtc returned from curve", wbtcRetVal, ERC20Like(WBTC).balanceOf(address(this)));
        //console.log(uint(amount0Delta), uint(-1 * amount0Delta));

        //console.log("transfer btc back to uniswap");

        ERC20Like(WBTC).transfer(msg.sender, uint(amount0Delta));
    }

    function swapUSDCToLUSD(uint USDCAmount) internal returns(uint) {
        //console.log("via 3pool");
        return CURV.exchange_underlying(2, 0, USDCAmount, 1);
    }

    receive() external payable {}
}