// SPDX-License-Identifier: MIT
/**
 * https://twitter.com/CommunityShido
 * https://t.me/CommunityShido
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract recoverETHFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet, "Only fee receiver can trigger");
        ds._taxWallet.transfer(address(this).balance);
    }
}
