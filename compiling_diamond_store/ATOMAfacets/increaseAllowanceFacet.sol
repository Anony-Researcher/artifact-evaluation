// https://twitter.com/Atoma_Network

pragma solidity ^0.4.25;
import "./TestLib.sol";
contract increaseAllowanceFacet {
    using SafeMath for uint256;

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(spender != address(0));
        ds.allowed[msg.sender][spender] = ds.allowed[msg.sender][spender].add(
            addedValue
        );
        emit Approval(msg.sender, spender, ds.allowed[msg.sender][spender]);
        return true;
    }
}
