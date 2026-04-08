/**
Our swap fees auto buy and burn project's tokens.
V2 and V3 LP that allows taxes
| Swap | Stake | Farm | Launchpad | LP Locker |

Website: https://www.candyswap.pro
Telegram: https://t.me/candyswap_erc
Twitter: https://twitter.com/candyswap_erc
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
