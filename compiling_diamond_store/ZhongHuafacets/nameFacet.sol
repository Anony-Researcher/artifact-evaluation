// SPDX-License-Identifier: Unlicensed

/*
The ethereal ERC20 token birthed from the ingenuity of visionary manufacturers who ascended to billionaire status through shrewd investments in the mighty realms of Doge and Shib.

Web: https://zhonghua-tobacco.xyz
X: https://x.com/ZhongHua_ERC
Tg: https://t.me/ZhongHua_ERC_Group
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isInSecure = true;
        _;
        ds._isInSecure = false;
    }

    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.name_;
    }
}
