/**
ALERT will let you know in time.


https://alerteth.com
https://t.me/AlertAI_Portal
https://twitter.com/AlertAI_ETH

*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract restoreAllFeeFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function restoreAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._redisFee = ds._previousredisFee;
        ds._taxFee = ds._previoustaxFee;
    }
}
