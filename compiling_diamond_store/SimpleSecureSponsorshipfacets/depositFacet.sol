// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract depositFacet {
    modifier onlyOpened() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.opened,
            "SimpleSecureSponsorship: sponsorship is already closed"
        );

        _;
    }

    function deposit(uint256 amount) public onlyOpened {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _sponsor = msg.sender;

        // transfer token to this contract
        ds.sponsorToken.transferFrom(_sponsor, address(this), amount);

        // update total deposit
        ds.totalDeposit_ = ds.totalDeposit_ + amount;

        // update vouch if the sponsor has ds.vouched
        if (hasVouched(_sponsor)) {
            ds.totalVouch_ = ds.totalVouch_ + amount;
        }

        // update sponsor
        if (ds.sponsors[_sponsor] == 0) {
            ds.totalSponsor_ = ds.totalSponsor_ + 1;
        }
        ds.sponsors[_sponsor] = ds.sponsors[_sponsor] + amount;
    }
    function hasVouched(address sponsor) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.vouched[sponsor];
    }
    function withdraw(uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.opened || !ds.vouched[msg.sender],
            "SimpleSecureSponsorship: withdraw is closed for vouchers"
        );
        require(
            ds.sponsors[msg.sender] >= amount,
            "SimpleSecureSponsorship: withdraw amount exceeds deposit"
        );
        address _sponsor = msg.sender;

        // transfer token to sponsor
        ds.sponsorToken.transfer(_sponsor, amount);

        // update total deposit
        ds.totalDeposit_ = ds.totalDeposit_ - amount;

        // update vouch if the sponsor has ds.vouched
        if (hasVouched(_sponsor)) {
            ds.totalVouch_ = ds.totalVouch_ - amount;
        }

        // update sponsor
        ds.sponsors[_sponsor] = ds.sponsors[_sponsor] - amount;
        if (ds.sponsors[_sponsor] == 0) {
            ds.vouched[_sponsor] = false;
            ds.totalSponsor_ = ds.totalSponsor_ - 1;
        }
    }
}
