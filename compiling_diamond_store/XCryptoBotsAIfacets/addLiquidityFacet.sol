/*
 _ (_)(_)(_) _                                                 (_)                               (_)(_)(_)(_) _                  (_)                                   _(_)_     (_)(_)(_)      
   (_)         (_)_       _  _  _               _  _  _  _  _   _ (_) _  _      _  _  _              (_)        (_)    _  _  _    _ (_) _  _   _  _  _  _               _(_) (_)_      (_)         
   (_)           (_)_  _ (_)(_)(_)_           _(_)(_)(_)(_)(_)_(_)(_)(_)(_)  _ (_)(_)(_) _           (_) _  _  _(_) _ (_)(_)(_) _(_)(_)(_)(_)_(_)(_)(_)(_)            _(_)     (_)_    (_)         
   (_)             (_)(_)        (_)_       _(_)  (_)        (_)  (_)       (_)         (_)          (_)(_)(_)(_)_ (_)         (_)  (_)     (_)_  _  _  _            (_) _  _  _ (_)   (_)         
   (_)          _  (_)             (_)_   _(_)    (_)        (_)  (_)     _ (_)         (_)          (_)        (_)(_)         (_)  (_)     _ (_)(_)(_)(_)_          (_)(_)(_)(_)(_)   (_)         
   (_) _  _  _ (_) (_)               (_)_(_)      (_) _  _  _(_)  (_)_  _(_)(_) _  _  _ (_)          (_)_  _  _ (_)(_) _  _  _ (_)  (_)_  _(_) _  _  _  _(_)         (_)         (_) _ (_) _       
      (_)(_)(_)    (_)                _(_)        (_)(_)(_)(_)      (_)(_)     (_)(_)(_)            (_)(_)(_)(_)      (_)(_)(_)       (_)(_)  (_)(_)(_)(_)           (_)         (_)(_)(_)(_)      
                                 _  _(_)          (_)                                                                                                                                          

Revolutionizing the way crypto trading supported by AI

Twitter: https://twitter.com/CryptoBotAITech
Telegram: 
	Official: https://t.me/CryptoBotAIOfficial
    Alerts Bot: https://t.me/CryptoBotsAIAlerts
	Snipe & Shill & Referal Bots: https://t.me/CryptoBotsAIBot
Website: https://x-cryptobots.com
WhitePaper: https://cryptobotsai.gitbook.io/whitepaper/
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract addLiquidityFacet is ERC20 {
    using SafeMath for uint256;

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // add the liquidity
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadAddress,
            block.timestamp
        );
    }
}
