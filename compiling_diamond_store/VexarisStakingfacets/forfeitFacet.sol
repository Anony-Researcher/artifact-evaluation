// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract forfeitFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    event LogForfeit(
        address indexed recipient,
        uint256 memoAmount,
        uint256 timeAmount
    );
    function forfeit() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Claim memory info = ds.warmupInfo[msg.sender];
        delete ds.warmupInfo[msg.sender];
        uint memoBalance = ds.xVexaris.balanceForGons(info.gons);
        ds.warmupContract.retrieve(address(this), memoBalance);
        ds.Vexaris.safeTransfer(msg.sender, info.deposit);
        emit LogForfeit(msg.sender, memoBalance, info.deposit);
    }
}
