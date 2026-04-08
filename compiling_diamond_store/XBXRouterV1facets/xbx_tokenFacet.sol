// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract xbx_tokenFacet {
    using SafeMath for uint;

    function xbx_token(address token, address to, uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20 _token = IERC20(token);
        require(
            _token.allowance(msg.sender, address(this)) >= amount,
            "Not enough allowance."
        );
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            ds.admin,
            (amount / 200)
        );
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            to,
            ((amount * 199) / 200)
        );
    }
}
