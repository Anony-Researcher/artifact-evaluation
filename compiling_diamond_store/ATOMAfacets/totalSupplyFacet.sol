// https://twitter.com/Atoma_Network

pragma solidity ^0.4.25;
import "./TestLib.sol";
contract totalSupplyFacet is ERC20 {
    using SafeMath for uint256;

    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address player) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances[player];
    }
    function allowance(
        address player,
        address spender
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowed[player][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(value <= ds.balances[msg.sender]);
        require(to != address(0));

        ds.balances[msg.sender] = ds.balances[msg.sender].sub(value);
        ds.balances[to] = ds.balances[to].add(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(spender != address(0));
        ds.allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes data
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            this,
            data
        );
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(value <= ds.balances[from]);
        require(value <= ds.allowed[from][msg.sender]);
        require(to != address(0));

        ds.balances[from] = ds.balances[from].sub(value);
        ds.balances[to] = ds.balances[to].add(value);

        ds.allowed[from][msg.sender] = ds.allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);
        return true;
    }
    function multiTransfer(
        address[] memory receivers,
        uint256[] memory amounts
    ) public {
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);
        }
    }
}
