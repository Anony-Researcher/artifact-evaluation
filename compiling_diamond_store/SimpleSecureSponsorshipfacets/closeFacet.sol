// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract closeFacet {
    modifier onlyOpened() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.opened,
            "SimpleSecureSponsorship: sponsorship is already closed"
        );

        _;
    }

    event Close(uint256 amount);
    function close() public onlyOpened {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.sponsoredParty,
            "SimpleSecureSponsorship: can only be closed by sponsored party"
        );
        require(
            ds.totalDeposit_ / 2 <= ds.totalVouch_,
            "SimpleSecureSponsorship: not enough vouch"
        );

        // transfer ds.vouched sponsorships to sponsored party
        ds.sponsorToken.transfer(ds.sponsoredParty, ds.totalVouch_);

        // update total deposit
        ds.totalDeposit_ = ds.totalDeposit_ - ds.totalVouch_;

        // update vouch if the sponsor has ds.vouched
        ds.totalVouch_ = 0;

        // close this sponsor contract
        ds.opened = false;

        emit Close(ds.totalVouch_);
    }
}
