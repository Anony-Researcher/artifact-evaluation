// SPDX-License-Identifier: MIT
/*

Gambit is a pioneering betting platform leveraging blockchain technology to redefine the gaming experience. 
Distinguished from traditional betting platforms, Gambit unveils a novel selection of betting games,
underpinned by algorithmic designs that guarantee equitable play. 

Website : https://gambit.game/
TG : https://t.me/play_gambit
X : https://twitter.com/Play_Gambit

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
