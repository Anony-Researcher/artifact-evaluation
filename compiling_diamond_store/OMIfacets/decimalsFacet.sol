/*
Ominus - The Ominus stands at the forefront of innovation in DeFi infrastructure
OMI infrastructure
The Omi ecosystem includes a variety of subprotocols, each designed to integrate and enhance the functionality of its stablecoins 
within the broader decentralized finance (DeFi) landscape. These subprotocols play a crucial role in ensuring the versatility, 
efficiency, and utility of the $OMI stablecoins.
WEB | https://ominus.codes
TG  | https://t.me/OminusPortal
X   | https://twitter.com/Ominus_ERC20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
