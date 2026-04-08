// SPDX-License-Identifier: Unlicensed

/*
We welcome you to Ultra AI Tech!

Powering the future of AI with our HPC data center | Launchpad | IaaS platform | AIaaS | BaaS | AI Marketplace | Powered by $AITECH token

Web: https://ultra-aitech.xyz
App: https://stake.ultra-aitech.xyz
Tg: https://t.me/ultra_aitech_official
X: https://x.com/ULTRA_AITECH
Docs: https://medium.com/@ultra.aitech
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isGuarded = true;
        _;
        ds._isGuarded = false;
    }

    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.name_;
    }
}
