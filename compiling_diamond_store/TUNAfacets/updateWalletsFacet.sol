/**

    https://twitter.com/tunacoineth

**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract updateWalletsFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function updateWallets(
        address _team,
        address _marketing,
        address _dev
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._operationsWallet);
        ds._teamWallet = payable(_team);
        ds._marketingWallet = payable(_marketing);
        ds._devWallet = payable(_dev);
    }
}
