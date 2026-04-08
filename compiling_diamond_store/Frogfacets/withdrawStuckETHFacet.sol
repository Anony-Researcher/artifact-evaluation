/*
 * SPDX-License-Identifier: MIT
 * https://twitter.com/FrogcoinOnEth
 * https://t.me/FROG_COIN_ETH
 * https://frogcoineth.vip/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract withdrawStuckETHFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function withdrawStuckETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds._marketingWallet,
            "Only fee receiver can trigger"
        );
        ds._marketingWallet.transfer(address(this).balance);
    }
}
