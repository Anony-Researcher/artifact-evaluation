// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./TestLib.sol";
contract setBlockNumberFacet is ERC20, Manageable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier nonReentrant() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // On the first call to nonReentrant, _notEntered will be true
        require(ds._status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        ds._status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        ds._status = _NOT_ENTERED;
    }

    event SetBlockNumber(uint256 blockNumber);
    function setBlockNumber() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blockNumber = block.number;
        emit SetBlockNumber(ds.blockNumber);
    }
}
