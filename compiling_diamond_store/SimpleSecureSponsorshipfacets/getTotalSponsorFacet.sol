// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getTotalSponsorFacet {
    modifier onlyOpened() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.opened,
            "SimpleSecureSponsorship: sponsorship is already closed"
        );

        _;
    }

    function getTotalSponsor() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.totalSponsor_;
    }
}
