// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setVouchedFacet {
    modifier onlyOpened() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.opened,
            "SimpleSecureSponsorship: sponsorship is already closed"
        );

        _;
    }

    function setVouched(bool value) public onlyOpened {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _sponsor = msg.sender;

        if (ds.vouched[_sponsor] != value) {
            ds.vouched[msg.sender] = value;

            // update vouch if sponsor has ds.vouched
            if (value) {
                ds.totalVouch_ = ds.totalVouch_ + ds.sponsors[_sponsor];
            } else {
                ds.totalVouch_ = ds.totalVouch_ - ds.sponsors[_sponsor];
            }
        }
    }
}
