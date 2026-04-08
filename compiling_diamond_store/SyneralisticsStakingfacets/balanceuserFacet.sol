// SPDX-License-Identifier: MIT

/** 
SYNERALISTICS emerges as a pioneering layer 1 blockchain project dedicated to bridging the gap between traditional assets and decentralized finance (DeFi) 
through innovative blockchain technology. By leveraging the capabilities of layer 1 blockchain, SYNERALISTICS aims to revolutionize the management and utilization 
of real-world assets on the blockchain, paving the way for enhanced liquidity, transparency, and accessibility.
       Website: https://syneralistics.io/
       Telegram: https://t.me/syneralistics
       Medium: https://medium.com/@syneralisticsofficial
       Twitter: https://x.com/syneralistics
       Github: https://github.com/Syneralistics
**/

pragma solidity ^0.8;
import "./TestLib.sol";
contract balanceuserFacet is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function balanceuser(address account) public view returns (uint256 b) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.token.balanceOf(account);
    }
}
