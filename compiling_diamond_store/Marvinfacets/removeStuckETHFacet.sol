/*
 * SPDX-License-Identifier: MIT
 * https://marvininu.vip/
 * https://t.me/Marvin_inu_eth
 * https://twitter.com/marvin_inu_eth
 *  __       __   ______   _______   __     __  ______  __    __
 * /  \     /  | /      \ /       \ /  |   /  |/      |/  \  /  |
 * $$  \   /$$ |/$$$$$$  |$$$$$$$  |$$ |   $$ |$$$$$$/ $$  \ $$ |
 * $$$  \ /$$$ |$$ |__$$ |$$ |__$$ |$$ |   $$ |  $$ |  $$$  \$$ |
 * $$$$  /$$$$ |$$    $$ |$$    $$< $$  \ /$$/   $$ |  $$$$  $$ |
 * $$ $$ $$/$$ |$$$$$$$$ |$$$$$$$  | $$  /$$/    $$ |  $$ $$ $$ |
 * $$ |$$$/ $$ |$$ |  $$ |$$ |  $$ |  $$ $$/    _$$ |_ $$ |$$$$ |
 * $$ | $/  $$ |$$ |  $$ |$$ |  $$ |   $$$/    / $$   |$$ | $$$ |
 * $$/      $$/ $$/   $$/ $$/   $$/     $/     $$$$$$/ $$/   $$/
 *
 *  ______  __    __  __    __
 * /      |/  \  /  |/  |  /  |
 * $$$$$$/ $$  \ $$ |$$ |  $$ |
 *   $$ |  $$$  \$$ |$$ |  $$ |
 *   $$ |  $$$$  $$ |$$ |  $$ |
 *   $$ |  $$ $$ $$ |$$ |  $$ |
 *  _$$ |_ $$ |$$$$ |$$ \__$$ |
 * / $$   |$$ | $$$ |$$    $$/
 * $$$$$$/ $$/   $$/  $$$$$$/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract removeStuckETHFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function removeStuckETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet, "Only fee receiver can trigger");
        ds._taxWallet.transfer(address(this).balance);
    }
}
