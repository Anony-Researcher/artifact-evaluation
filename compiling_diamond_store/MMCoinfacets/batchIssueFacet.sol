pragma solidity ^0.4.17;
import "./TestLib.sol";
contract batchIssueFacet is Pausable, StandardToken, BlackList {
    function batchIssue(
        address[] memory recipients,
        uint256[] memory amounts
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(recipients.length == amounts.length);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0));
            require(amounts[i] > 0);
            require(_totalSupply.add(amounts[i]) <= ds.MAX_SUPPLY);
            require(
                balances[recipients[i]].add(amounts[i]) >
                    balances[recipients[i]]
            );
            balances[recipients[i]] = balances[recipients[i]].add(amounts[i]);
            _totalSupply = _totalSupply.add(amounts[i]);
            IssueToAddress(recipients[i], amounts[i]);
            Transfer(address(0), recipients[i], amounts[i]);
        }
    }
}
