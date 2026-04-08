//SPDX-License-Identifier: MIT

/**


https://x.com/discussingfilm/status/1765939814493515879?s=46&t=AAeulnrJ8097JIfGWHF2cQ
https://t.me/Akira_ERC

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
