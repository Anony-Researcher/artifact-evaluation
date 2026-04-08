/*

  _    _    _    _     _    _    _  
 / \  / \  / \  / \   / \  / \  / \ 
( I )( S )( H )( I ) ( I )( N )( U )
 \_/  \_/  \_/  \_/   \_/  \_/  \_/ 

Meet ISHI, the dog responsible for all Shiba Inu in the world today

Website: https://ishiinu.org/

Telegram: https://t.me/ishicoin

X: https://twitter.com/IshiCoin

*/

pragma solidity 0.8.23;
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
