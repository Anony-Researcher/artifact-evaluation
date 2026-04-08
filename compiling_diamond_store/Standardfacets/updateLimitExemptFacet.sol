// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract updateLimitExemptFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    function updateLimitExempt(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.maxWallet > 0);
        ds.limitExempt[account] = !ds.limitExempt[account];
    }
}
