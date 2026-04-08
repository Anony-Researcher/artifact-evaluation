// SPDX-License-Identifier: MIT

/**

TensorVerse democratizes the landscape of AI, making it accessible to everyone.

Leveraging the capabilities of Bittensor, users can effortlessly deploy AI applications 
without the need for coding expertise, thanks to an intuitive interface designed for accessibility. 

https://tensorverse.cloud/
https://t.me/tensorverseAI
https://twitter.com/tensorverseAI
https://docs.tensorverse.cloud/

**/
pragma solidity 0.8.20;
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
