// SPDX-License-Identifier: UNLICENSED
/*


LLLLLLLLLLL                       FFFFFFFFFFFFFFFFFFFFFF                  GGGGGGGGGGGGG          
L:::::::::L                       F::::::::::::::::::::F               GGG::::::::::::G          
L:::::::::L                       F::::::::::::::::::::F             GG:::::::::::::::G          
LL:::::::LL                       FF::::::FFFFFFFFF::::F            G:::::GGGGGGGG::::G          
  L:::::L                           F:::::F       FFFFFF           G:::::G       GGGGGG          
  L:::::L                           F:::::F                       G:::::G                        
  L:::::L                           F::::::FFFFFFFFFF             G:::::G                        
  L:::::L                           F:::::::::::::::F             G:::::G    GGGGGGGGGG          
  L:::::L                           F:::::::::::::::F             G:::::G    G::::::::G          
  L:::::L                           F::::::FFFFFFFFFF             G:::::G    GGGGG::::G          
  L:::::L                           F:::::F                       G:::::G        G::::G          
  L:::::L         LLLLLL            F:::::F                        G:::::G       G::::G          
LL:::::::LLLLLLLLL:::::L          FF:::::::FF                       G:::::GGGGGGGG::::G          
L::::::::::::::::::::::L          F::::::::FF                        GG:::::::::::::::G          
L::::::::::::::::::::::L          F::::::::FF                          GGG::::::GGG:::G          
LLLLLLLLLLLLLLLLLLLLLLLL          FFFFFFFFFFF                             GGGGGG   GGGG    

Telegram:https://t.me/LFGonethereum
Twitter: https://twitter.com/LfgOneth
Website: https://www.lfgoneth.xyz/
*/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract reduceFeeFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
