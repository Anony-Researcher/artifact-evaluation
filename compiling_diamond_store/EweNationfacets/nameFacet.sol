/**
 Telegram: https://t.me/eweERC
 Website: https://ewenation.eu

 Welcome $EWE friends to the $EWE NATION WHICH IS A TASTY SECRET SOCIETY AGAINST WORLD CONSPIRACY! 
 $EWE may be brainless and feeble minded. 
 I have almost no knowledge in what im doing so please don't take me too seriously! or any of the EWE PLEBS! 
 We are all just blind EWE bros trying to crack the code on ze earth to get some of that rockefellar money. Dont fight me fight the $EWES bitch. All complaints se nd them to @EWELOVESU thanx 🔴
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
