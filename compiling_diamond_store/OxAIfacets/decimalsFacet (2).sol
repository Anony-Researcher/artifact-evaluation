/*
0xAI a project that aims to revolutionize the application of artificial intelligence and cryptocurrency. 

https://0x-ai.org
https://twitter.com/0xAI_Community
https://t.me/CryptoAI_Official
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;
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
