/**

EclipseStake - $EPS

Get self repaying, 0% interest loans on your LSD tokens without any risk of liquidation.

Website:  https://eclipsestake.xyz
Telegram: https://t.me/eclipsestake_erc20
Twitter:  https://twitter.com/eclipsestake
Medium:   https://medium.com/@eclipsestake_erc20

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
