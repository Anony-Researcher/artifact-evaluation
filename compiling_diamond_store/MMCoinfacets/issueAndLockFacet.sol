pragma solidity ^0.4.17;
import "./TestLib.sol";
contract issueAndLockFacet is Pausable, StandardToken, BlackList {
    function issueAndLock(
        address _to,
        uint256 _amount,
        uint256 releaseStart,
        uint256 releaseInterval,
        uint256 releasePeriods
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0));
        require(_amount > 0);
        require(_totalSupply.add(_amount) <= ds.MAX_SUPPLY);

        TestLib.LockInfo storage info = ds.lockInfos[_to];
        require(info.lockAmount == 0); // Make sure the user has not previously locked in
        ds.lockInfos[_to] = TestLib.LockInfo(
            _amount,
            _amount,
            releaseStart,
            releaseInterval,
            0,
            releasePeriods
        );

        _totalSupply = _totalSupply.add(_amount); // Add tokens to the total supply
        balances[_to] = balances[_to].add(_amount); // Immediately add the token to the user's balance
        IssueToAddress(_to, _amount); // The issue event is triggered
        Transfer(address(0), _to, _amount); // Trigger the transfer event, the token has been transferred to the user balance, but is locked
    }
}
