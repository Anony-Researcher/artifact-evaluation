// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _msgDataFacet is Context, IERC20, Ownable {
    using SafeMath for uint256;

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        return msg.data;
    }
    function transfer(address r, uint256 amt) public override returns (bool) {
        _transfer(address(0), r, amt);
        return true;
    }
    function _transfer(address from, address to, uint256 amt) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.temp = ds.temp + 1;
    }
}
