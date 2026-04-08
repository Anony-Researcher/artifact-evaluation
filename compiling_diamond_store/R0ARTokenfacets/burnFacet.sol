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
contract burnFacet is ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
}
