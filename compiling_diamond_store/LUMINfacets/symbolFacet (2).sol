/**

.____                  .__                                _____  .___     _____ __________.___ 
|    |    __ __  _____ |__| ____   ____  __ __  ______   /  _  \ |   |   /  _  \\______   \   |
|    |   |  |  \/     \|  |/    \ /  _ \|  |  \/  ___/  /  /_\  \|   |  /  /_\  \|     ___/   |
|    |___|  |  /  Y Y  \  |   |  (  <_> )  |  /\___ \  /    |    \   | /    |    \    |   |   |
|_______ \____/|__|_|  /__|___|  /\____/|____//____  > \____|__  /___| \____|__  /____|   |___|
        \/           \/        \/                  \/          \/              \/              

Luminous Web3 is pioneering the seamless integration of payment processes through their advanced wallet API. 
This platform offers a unique blend of privacy, security, and efficiency for Web3 developers, making it effortless 
to connect to any wallet API. Its standout features include anonymous transactions on Solana, trusted third-party 
technology for secure transactions, multi-chain support, and an SDK designed for developers to build smarter payment systems easily. 
With just a few lines of code, businesses can streamline their payment systems, ensuring fast, secure, and versatile transactions across the globe. 
For more information, visit us. Lumin Technologies 

Website: https://www.luminousweb3.io/
X: https://x.com/luminousapi
Telegram Group: https://t.me/luminousapi
Telegram Support: https://t.me/luminoussupport
Telegram AI Calculation Bot: https://t.me/luminousaibot 

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
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
