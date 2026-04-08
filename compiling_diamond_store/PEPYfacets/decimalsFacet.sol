//SPDX-License-Identifier: MIT

/**
 _______   ________  _______   __      __ 
/       \ /        |/       \ /  \    /  |
$$$$$$$  |$$$$$$$$/ $$$$$$$  |$$  \  /$$/ 
$$ |__$$ |$$ |__    $$ |__$$ | $$  \/$$/  
$$    $$/ $$    |   $$    $$/   $$  $$/   
$$$$$$$/  $$$$$/    $$$$$$$/     $$$$/    
$$ |      $$ |_____ $$ |          $$ |    
$$ |      $$       |$$ |          $$ |    
$$/       $$$$$$$$/ $$/           $$/     
  Telegram: https://t.me/pepycoin
  Website: https://pepycoin.com/
  Twitter: https://twitter.com/PepyCoin
*/
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
