/** 
Website: http://synthtpu.cloud
Telegram: https://t.me/SynthTPU
Twitter: https://twitter.com/SynthTPU
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract maxBuyTxTokensFacet is Ownable {
    using Address for address;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyTeam() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.teamMembers[_msgSender()] || msg.sender == owner(),
            "Caller is not a team member"
        );
        _;
    }

    function maxBuyTxTokens() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._maxBuyTxAmount / (10 ** _decimals);
    }
}
