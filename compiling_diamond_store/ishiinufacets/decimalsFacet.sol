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
