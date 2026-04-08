//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract recoverEthFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function recoverEth() internal onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function Withdraw() external onlyOwner {
        recoverEth();
    }
}
