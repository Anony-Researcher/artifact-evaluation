// SPDX-License-Identifier: UNLICENSE

/*

BOOM - Deploying made easy with BOOM on L2.


TG: https://t.me/Boom_ERC20
BOT:  https://t.me/BoomDeployerBot
WEB: https://boomerc.sbs/
TWITTER: https://twitter.com/Boom_CoinERC20.

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
