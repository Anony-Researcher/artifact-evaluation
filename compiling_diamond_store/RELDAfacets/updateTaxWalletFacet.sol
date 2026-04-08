// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract updateTaxWalletFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function updateTaxWallet(address payable newWallet) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds._taxWallet,
            "You are not allowed to change the tax wallet"
        );
        ds._taxWallet = newWallet;
        ds._isExcludedFromFee[ds._taxWallet] = true;
    }
}
