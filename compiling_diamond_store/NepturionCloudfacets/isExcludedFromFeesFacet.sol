/*

    Website: https://www.nepturion.cloud/
    Try App: https://www.nepturion.cloud/auth
    Docs: https://docs.nepturion.cloud/
    Telegram: https://t.me/nepturioncloud
    X: https://x.com/NepturionCloud
    YouTube: https://www.youtube.com/@NepturionCloud
    GitHub: https://github.com/Nepturion-Cloud

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
