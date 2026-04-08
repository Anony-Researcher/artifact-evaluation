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
contract burnFromFacet is ERC20 {
    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }
    function _burnFrom(address account_, uint256 amount_) public virtual {
        uint256 decreasedAllowance_ = allowance(account_, msg.sender).sub(
            amount_,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}
