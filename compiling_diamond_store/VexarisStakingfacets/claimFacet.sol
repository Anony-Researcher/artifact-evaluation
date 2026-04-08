// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract claimFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    event LogClaim(address indexed recipient, uint256 amount);
    function claim(address _recipient) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Claim memory info = ds.warmupInfo[_recipient];
        if (ds.epoch.number >= info.expiry && info.expiry != 0) {
            delete ds.warmupInfo[_recipient];
            uint256 amount = ds.xVexaris.balanceForGons(info.gons);
            ds.warmupContract.retrieve(_recipient, amount);
            emit LogClaim(_recipient, amount);
        }
    }
}
