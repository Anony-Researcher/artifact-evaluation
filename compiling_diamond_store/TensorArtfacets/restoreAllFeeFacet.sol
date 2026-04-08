/**
ART CREATED BY TAO AI


Website: https://tensor.art
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.24;
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
