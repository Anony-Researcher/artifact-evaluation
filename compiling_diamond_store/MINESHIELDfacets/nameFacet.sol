/**
// SPDX-License-Identifier: MIT
/** 
MineShield is a groundbreaking blockchain project that combines the functionalities of audit and GPU mining to revolutionize the crypto mining industry.
MineShield represents a paradigm shift in the crypto mining industry, offering a unique blend of audit and GPU mining capabilities to enhance security, efficiency, and trust in the mining ecosystem. With its innovative approach and community-driven ethos, MineShield is poised to shape the future of crypto mining
       Website: https://mineshield.cloud/
       Telegram: https://t.me/mineshield_portal
       Medium: https://medium.com/@mineshieldproject
       Twitter: https://x.com/MineShieldERC
       Youtube: https://www.youtube.com/@ProjectMineshield
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
