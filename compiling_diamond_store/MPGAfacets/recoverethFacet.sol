/*
https://www.mpgaeth.xyz/

https://twitter.com/mgpa_eth

https://t.me/mysterylaunchmpga
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract recoverethFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function recovereth() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet, "Only fee receiver can trigger");
        ds._taxWallet.transfer(address(this).balance);
    }
}
