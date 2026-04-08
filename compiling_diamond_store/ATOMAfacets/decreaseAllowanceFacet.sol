// https://twitter.com/Atoma_Network

pragma solidity ^0.4.25;
import "./TestLib.sol";
contract decreaseAllowanceFacet {
    using SafeMath for uint256;

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(spender != address(0));
        ds.allowed[msg.sender][spender] = ds.allowed[msg.sender][spender].sub(
            subtractedValue
        );
        emit Approval(msg.sender, spender, ds.allowed[msg.sender][spender]);
        return true;
    }
}
