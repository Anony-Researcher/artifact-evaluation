// Sources flattened with hardhat v2.19.5 https://hardhat.org

// SPDX-License-Identifier: MIT

// File contracts/interfaces/IERC20.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.24;
import "./TestLib.sol";
contract approveTokenFacet is Ownable {
    event ApproveToken(address token, bool value);
    event RouterAddressSet(address routerAddress);
    function approveToken(address token, bool value) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.approvedTokens[token] = value;
        emit ApproveToken(token, value);
    }
    function setRouterAddress(address _routerAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_routerAddress == address(0)) revert ZeroAddress();
        ds.routerAddress = _routerAddress;
        emit RouterAddressSet(_routerAddress);
    }
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
