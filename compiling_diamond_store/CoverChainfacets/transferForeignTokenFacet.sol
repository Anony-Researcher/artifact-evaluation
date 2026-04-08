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
contract transferForeignTokenFacet is ERC20, Ownable {
    event TransferForeignToken(address token, uint256 amount);
    function transferForeignToken(
        address _token,
        address _to
    ) public returns (bool _sent) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_token != address(0), "_token address cannot be 0");
        require(
            msg.sender == ds.TreasuryAddress,
            "only ds.TreasuryAddress can withdraw"
        );
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }
}
