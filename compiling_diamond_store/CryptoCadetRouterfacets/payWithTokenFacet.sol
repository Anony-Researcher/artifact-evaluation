//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract payWithTokenFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event TokenTransfer(
        address indexed sender,
        uint256 amount,
        uint256 timestamp,
        bool received
    );
    event ReferralEarned(
        address indexed sender,
        address indexed referrer,
        uint256 commission,
        uint256 timestamp
    );
    function payWithToken(
        address _payee,
        address _token,
        uint256 _amount,
        address _referrer,
        uint8 _refPercent
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount > 0, "nonzero amount required");
        require(
            _refPercent <= 100,
            "referral commission cannot exceed 100 percent"
        );
        IToken token = IToken(_token);
        uint256 tax = (_amount * ds.fee) / 100;
        uint256 commission = ((_amount - tax) * _refPercent) / 100;
        uint256 remainder = _amount - tax - commission;
        token.transferFrom(msg.sender, ds.owner, tax);
        token.transferFrom(msg.sender, _referrer, commission);
        token.transferFrom(msg.sender, _payee, remainder);

        emit TokenTransfer(msg.sender, remainder, block.timestamp, true);
        emit ReferralEarned(msg.sender, _referrer, block.timestamp, commission);

        return true;
    }
}
