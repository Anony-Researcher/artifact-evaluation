/**
$CHEERS to the Bull
Web: https://cheers-erc.xyz/
TG: https://t.me/cheersentry
X: https://x.com/pepechampagne
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
