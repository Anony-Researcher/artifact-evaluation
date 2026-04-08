// SPDX-License-Identifier: MIT

/* The Official HahaHash Meme Token Contract - ERC20

██╗  ██╗ █████╗ ██╗  ██╗ █████╗ ██╗  ██╗ █████╗ ███████╗██╗  ██╗
██║  ██║██╔══██╗██║  ██║██╔══██╗██║  ██║██╔══██╗██╔════╝██║  ██║
███████║███████║███████║███████║███████║███████║███████╗███████║
██╔══██║██╔══██║██╔══██║██╔══██║██╔══██║██╔══██║╚════██║██╔══██║
██║  ██║██║  ██║██║  ██║██║  ██║██║  ██║██║  ██║███████║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                

*/

// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
