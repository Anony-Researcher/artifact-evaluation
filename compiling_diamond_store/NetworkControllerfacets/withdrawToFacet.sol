// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawToFacet is Ownable {
    modifier allowedToWithdraw() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || ds.withdrawApprovals[msg.sender],
            "WITHDRAW APPROVED ONLY!"
        );
        _;
    }

    function withdrawTo(
        address destination,
        uint256 amount
    ) external allowedToWithdraw {
        uint256 amountToWithdraw = Math.min(amount, address(this).balance);

        (bool sent, ) = destination.call{value: amountToWithdraw}("");
        require(sent, "FAILURE");
    }
}
