//SPDX-License-Identifier: MIT

/**
 S)ssss  W)      ww I)iiii F)ffffff T)tttttt   A)aa   I)iiii 
S)    ss W)      ww   I)   F)          T)     A)  aa    I)   
 S)ss    W)  ww  ww   I)   F)fffff     T)    A)    aa   I)   
     S)  W)  ww  ww   I)   F)          T)    A)aaaaaa   I)   
S)    ss W)  ww  ww   I)   F)          T)    A)    aa   I)   
 S)ssss   W)ww www  I)iiii F)          T)    A)    aa I)iiii 
Telegram: https://t.me/SwiftAIB
Twitter: https://x.com/swift_aitoken?s=21
Website: https://swiftaibot.com/
*/
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
