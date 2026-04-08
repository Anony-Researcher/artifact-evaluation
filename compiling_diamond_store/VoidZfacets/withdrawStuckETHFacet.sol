// SPDX-License-Identifier: MIT
/*

VoidZ - Tokenization of Gaming Assets for Players and GPU Rental for Gaming Studios

Website: https://voidz.app/
Twitter/X: https://twitter.com/VoidZToken
Whitepaper: https://voidz.gitbook.io/voidz
TG: https://t.me/VoidZtoken

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
