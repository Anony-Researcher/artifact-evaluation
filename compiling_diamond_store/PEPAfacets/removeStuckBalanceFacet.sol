// SPDX-License-Identifier: MIT
/**
 * https://t.me/PepaOnEth
 * https://twitter.com/PepaEth
 * https://www.PepaEthCoin.com/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract removeStuckBalanceFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function removeStuckBalance() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet, "Only fee receiver can trigger");
        ds._taxWallet.transfer(address(this).balance);
    }
}
