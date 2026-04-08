// SPDX-License-Identifier: MIT

/*
    Website:  https://www.metachainai.net
    Network:  https://network.metachainai.net
    
    Chat:     https://chat.metachainai.net
    Docs:     https://docs.metachainai.net

    Telegram: https://t.me/metachainai_portal
    Twitter:  https://twitter.com/MetaChain_AI

*/
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
