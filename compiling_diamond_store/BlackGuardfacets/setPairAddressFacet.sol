// File: Ownable.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./TestLib.sol";
contract setPairAddressFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogSetPairAddress(address indexed pairAddress);
    function setPairAddress(address newPairAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newPairAddress != address(0),
            "Pair address cannot be the zero address"
        );
        ds.pairAddress = newPairAddress;
        ds.pairContract = IPancakeSwapPair(newPairAddress);
        emit LogSetPairAddress(newPairAddress);
    }
    function setFeeExempt(address account, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "Zero address");
        ds._isFeeExempt[account] = exempt;
    }
}
