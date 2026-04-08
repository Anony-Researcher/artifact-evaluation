/**
// SPDX-License-Identifier: MIT
/*
            Telegram - https://t.me/SphynxAIERC

            Website - https://www.sphynx-ai.com/

            Twitter - https://twitter.com/SphynxAiERC


*/
pragma solidity 0.8.24;
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
