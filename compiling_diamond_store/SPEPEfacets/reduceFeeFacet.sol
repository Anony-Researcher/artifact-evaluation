// SPDX-License-Identifier: UNLICENSE

/*
    MISSED PEPE? DON'T MISS SUPER PEPE!
    https://superpepecoin.vip/
    https://twitter.com/super_pepecoin
    https://t.me/superpepecoineth
    https://www.tiktok.com/@victorreznov101/video/7163066179639201070
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
