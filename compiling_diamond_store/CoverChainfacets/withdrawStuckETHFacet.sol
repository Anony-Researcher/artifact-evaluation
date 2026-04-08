// SPDX-License-Identifier: MIT
/*
CoverChain is a cryptocurrency emphasizing security, privacy, and mobile accessibility. 
It utilizes IPFS and distributed technologies for scalability and offers features like untraceable payments and blockchain analysis resistance. 
With a focus on inclusivity and usability, CoverChain aims to distribute wealth globally while addressing real-world issues economically.

Website: https://coverchain.net/
Twitter: https://twitter.com/CoverChainNet
Telegram: https://t.me/CoverChainNet

*/
pragma solidity 0.8.12;
import "./TestLib.sol";
contract withdrawStuckETHFacet is ERC20, Ownable {
    function withdrawStuckETH() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        require(
            msg.sender == ds.TreasuryAddress,
            "only ds.TreasuryAddress can withdraw"
        );
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
}
