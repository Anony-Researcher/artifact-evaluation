//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract getBalanceFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function getBalance(
        address _tokenContractAddress
    ) internal view returns (uint256) {
        uint _balance = IERC20(_tokenContractAddress).balanceOf(address(this));
        return _balance;
    }
}
