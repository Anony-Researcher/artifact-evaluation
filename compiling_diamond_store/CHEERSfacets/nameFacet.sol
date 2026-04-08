/**
$CHEERS to the Bull
Web: https://cheers-erc.xyz/
TG: https://t.me/cheersentry
X: https://x.com/pepechampagne
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract nameFacet is Ownable {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
