// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.9;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier initializer() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.initialized, "ds.uniswapV2Pair is already ds.initialized");
        _;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
