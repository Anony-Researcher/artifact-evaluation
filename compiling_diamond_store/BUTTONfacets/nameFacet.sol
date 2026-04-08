//SPDX-License-Identifier: MIT
/**
Web: https://benjaminbutton.xyz
Twitter: Twitter.com/Benjamin_Butn
TG: https://t.me/BenjaminButton_ERC
**/

pragma solidity 0.8.23;
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
