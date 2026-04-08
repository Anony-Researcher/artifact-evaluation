// SPDX-License-Identifier: MIT

//  _______    ______    ______   _______
// /       \  /      \  /      \ /       \
// $$$$$$$  |/$$$$$$  |/$$$$$$  |$$$$$$$  |
// $$ |__$$ |$$$  \$$ |$$ |__$$ |$$ |__$$ |
// $$    $$< $$$$  $$ |$$    $$ |$$    $$<
// $$$$$$$  |$$ $$ $$ |$$$$$$$$ |$$$$$$$  |
// $$ |  $$ |$$ \$$$$ |$$ |  $$ |$$ |  $$ |
// $$ |  $$ |$$   $$$/ $$ |  $$ |$$ |  $$ |
// $$/   $$/  $$$$$$/  $$/   $$/ $$/   $$/

// website - https://www.r0ar.io/
// Discord -  https://bit.ly/fiercelabs
// Twitter - https://twitter.com/th3r0ar
// Redit - https://www.reddit.com/r/r0ar/
// Security Contact Info - security-dev-team@r0ar.io

pragma solidity 0.6.12;
import "./TestLib.sol";
contract _transferFacet is ERC20 {
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Pre-flight checks
        require(amount > 0, "Transfer amount must be greater than zero");

        if (sender == owner() || recipient == owner()) {
            super._transfer(sender, recipient, amount);
        } else {
            require(ds.tradingOpen == true, "Trading is not yet open.");
            super._transfer(sender, recipient, amount);
        }
    }
}
