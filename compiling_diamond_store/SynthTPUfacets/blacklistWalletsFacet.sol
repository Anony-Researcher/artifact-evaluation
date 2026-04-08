/** 
Website: http://synthtpu.cloud
Telegram: https://t.me/SynthTPU
Twitter: https://twitter.com/SynthTPU
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract blacklistWalletsFacet is Ownable {
    using Address for address;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyTeam() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.teamMembers[_msgSender()] || msg.sender == owner(),
            "Caller is not a team member"
        );
        _;
    }

    event WalletBlacklisted(address, address, uint256);
    function blacklistWallets(
        address[] calldata _wallets,
        bool _blacklist
    ) external onlyTeam {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < _wallets.length; i++) {
            if (_blacklist) {
                ds.blacklistCount++;
                emit WalletBlacklisted(tx.origin, _wallets[i], block.number);
            } else {
                if (ds.blacklist[_wallets[i]] != 0) ds.blacklistCount--;
            }
            ds.blacklist[_wallets[i]] = _blacklist ? block.number : 0;
        }
    }
}
