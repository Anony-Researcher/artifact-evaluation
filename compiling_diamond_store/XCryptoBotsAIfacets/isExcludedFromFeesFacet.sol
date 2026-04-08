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
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
