/*
// 🌐 𝐖𝐞𝐛𝐬𝐢𝐭𝐞: https://vault-101.org/
// 📱 𝐓𝐰𝐢𝐭𝐭𝐞𝐫: https://twitter.com/Vault_101Eth
// 📚 𝐆𝐢𝐭𝐛𝐨𝐨𝐤: https://vaults-organization-1.gitbook.io/vault-101/
// ✉️ https://t.me/vault101entry

   $𝐕𝟏𝟎𝟏

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
