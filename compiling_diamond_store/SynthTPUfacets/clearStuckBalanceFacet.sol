/** 
Website: http://synthtpu.cloud
Telegram: https://t.me/SynthTPU
Twitter: https://twitter.com/SynthTPU
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract clearStuckBalanceFacet is Ownable {
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

    function clearStuckBalance(
        uint256 amountPercentage,
        address adr
    ) external onlyTeam {
        uint256 amountETH = address(this).balance;

        if (amountETH > 0) {
            (bool sent, ) = adr.call{
                value: (amountETH * amountPercentage) / 100
            }("");
            require(sent, "Failed to transfer funds");
        }
    }
}
