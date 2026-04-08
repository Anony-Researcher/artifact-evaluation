pragma solidity ^0.5.0;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }
}
