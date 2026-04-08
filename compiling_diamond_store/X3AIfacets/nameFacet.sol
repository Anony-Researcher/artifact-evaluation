/*

X3 AI Network is a leading decentralized AI servicing protocol built for Web3. 
It connects to extensive on-chain and off-chain datasets, integrates and computes to establish a globally accessible data layer. 
This empowers the automation of hundreds of Web3 AI applications.

Website:     https://www.x3org.com
Telegram:    https://t.me/x3ai_org
Twitter:     https://twitter.com/x3ai_org

*/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
