// SPDX-License-Identifier: UNLICENSE

/*

Meet NOLAND, the first human with a Neuralink brain chip capable of playing video games and now able to use "Telepathy" powered by Neuralink to create social media posts. 

tg : https://t.me/NolandArbaugh_erc20

twitter : https://twitter.com/NolandArbaugh_

website : http://nolandarbaugh.site/

*/

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
