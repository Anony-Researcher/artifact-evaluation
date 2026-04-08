// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawToBulkFacet is Ownable {
    modifier allowedToWithdraw() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || ds.withdrawApprovals[msg.sender],
            "WITHDRAW APPROVED ONLY!"
        );
        _;
    }

    function withdrawToBulk(
        TestLib.BulkWithdraw[] calldata withdraws
    ) external allowedToWithdraw {
        for (uint8 i = 0; i < withdraws.length; ++i) {
            (bool sent, ) = withdraws[i].destination.call{
                value: withdraws[i].amount
            }("");

            require(sent, "FAILURE");
        }
    }
}
