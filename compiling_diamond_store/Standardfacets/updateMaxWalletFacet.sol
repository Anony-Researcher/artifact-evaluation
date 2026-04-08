// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract updateMaxWalletFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    function updateMaxWallet(uint256 newMaxWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newMaxWallet >= (ds.totalSupply * 5) / 1000);
        require(newMaxWallet <= ds.totalSupply);
        ds.maxWallet = newMaxWallet;
    }
}
