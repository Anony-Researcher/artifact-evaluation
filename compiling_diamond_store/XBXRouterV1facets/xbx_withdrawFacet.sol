// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract xbx_withdrawFacet {
    using SafeMath for uint;

    function xbx_withdraw(uint amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.admin, "Router: FORBIDDEN");
        IWETH(ds.WETH).withdraw(amount);
        require(
            amount <= address(this).balance,
            "Router: INSUFFICIENT_BALANCE"
        );
        payable(ds.admin).transfer(amount);
    }
}
