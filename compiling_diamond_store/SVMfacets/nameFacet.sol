// SPDX-License-Identifier: UNLICENSE

/*

SVM, or Satoshi Virtual Machine, is revolutionizing the blockchain space. SVM enables the creation of modular Bitcoin Layer 2 blockchains, offering unparalleled scalability and customization. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ac leo porta, dignissim leo nec, consectetur erat. Duis varius id erat at pellentesque. Morbi porttitor fermentum est ut varius. Morbi aliquam lectus id ornare varius. Integer vel dui metus. Nulla porttitor ipsum sed aliquet dignissim. Nunc auctor sodales molestie.

https://t.me/SVMERC

https://twitter.com/SVMERC20

https://svmnetwork.tech/

https://docs.svmnetwork.tech/

https://t.me/SVML2Bot

*/

pragma solidity ^0.8.18;
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
