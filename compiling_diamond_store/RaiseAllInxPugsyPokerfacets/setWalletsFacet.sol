// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setWalletsFacet {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._owner == msg.sender, "Caller =/= owner.");
        _;
    }

    function setWallets(
        address payable marketing,
        address payable project,
        address payable operations
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            marketing != address(0) &&
                project != address(0) &&
                operations != address(0),
            "Cannot be zero address."
        );
        ds._taxWallets.marketing = payable(marketing);
        ds._taxWallets.project = payable(project);
        ds._taxWallets.operations = payable(operations);
    }
}
