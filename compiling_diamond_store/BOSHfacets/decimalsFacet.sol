// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;
import "./TestLib.sol";
contract decimalsFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier onlyTaxWallet() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet, "Caller not authorized");
        _;
    }
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
