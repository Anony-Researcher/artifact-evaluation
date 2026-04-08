//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract payWithNativeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event NativeTransfer(
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
    function payWithNative(
        address _payee,
        address _referrer,
        uint8 _refPercent
    ) external payable returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.value > 0, "nonzero amount required");
        require(
            _refPercent <= 100,
            "referral commission cannot exceed 100 percent"
        );
        uint256 amount = msg.value;
        uint256 tax = (amount * ds.fee) / 100;
        uint256 commission = ((amount - tax) * _refPercent) / 100;
        uint256 remainder = amount - tax - commission;
        (bool success, ) = payable(ds.owner).call{value: tax}("");
        require(success);
        (bool os, ) = payable(_payee).call{value: remainder}("");
        require(os);
        (bool ref, ) = payable(_referrer).call{value: commission}("");
        require(ref);

        emit NativeTransfer(msg.sender, remainder, block.timestamp, true);
        emit ReferralEarned(msg.sender, _referrer, commission, block.timestamp);

        return true;
    }
}
