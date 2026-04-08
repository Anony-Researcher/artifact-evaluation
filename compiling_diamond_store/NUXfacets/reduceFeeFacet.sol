// SPDX-License-Identifier: UNLICENSE

/*
Earn real yield on any liquid asset powered by market volatility.
Get broad crypto exposure from blue chips to microcaps and earn real yield powered by market volatility and arbitrage. Simply wrap or buy into a pod, provide liquidity, sit back, relax, and earn NUX forever.

Web: https://nexusx.xyz
X: https://x.com/NexusX_ERC
Tg: https://t.me/nexusx_official
Medium: https://medium.com/@nexusx.finance
*/

pragma solidity 0.8.19;
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
