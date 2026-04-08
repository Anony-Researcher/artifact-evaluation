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
contract manualsendFacet is ERC20 {
    using SafeMath for uint256;

    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds.developmentWallet ||
                _msgSender() == ds.marketingWallet
        );
        bool success;
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
}
