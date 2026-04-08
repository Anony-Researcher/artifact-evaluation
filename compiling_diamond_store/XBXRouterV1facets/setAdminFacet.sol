// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract setAdminFacet {
    using SafeMath for uint;

    function setAdmin(address _admin) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.admin, "Router: FORBIDDEN");
        ds.admin = _admin;
    }
}
