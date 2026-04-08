//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract getUserFacet is DividendTracker, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    function getUser(
        address _user
    )
        external
        view
        returns (
            TestLib.User memory user,
            address account,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 balance
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (account, withdrawableDividends, totalDividends, balance) = getAccount(
            _user
        );
        user = ds.users[_user];
    }
}
