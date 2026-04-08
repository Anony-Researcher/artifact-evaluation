// SPDX-License-Identifier: MIT
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract contributeFacet {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    function contribute(
        uint256 amountInUSD,
        string memory code,
        address _referredBy
    ) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 userTokens;
        uint256 refPart;
        uint256 scorpPart;
        uint256 _contributionId = ds.contributionId.current();
        uint256 result;
        ds.contributionId.increment();
        if (msg.value > 0) {
            result = msg.value * getLatestPrice();
            amountInUSD = result / 10 ** 14;
            if (_referredBy != address(0)) {
                refPart = (msg.value * ds.referral[code]) / ds.deno;
                scorpPart = msg.value - refPart;
                (bool success, ) = ds.scorpionAddress.call{value: scorpPart}(
                    ""
                );
                require(success, "refund failed");
                (bool successTransfer, ) = _referredBy.call{value: refPart}("");
                require(successTransfer, "transfer failed");
            } else {
                (bool success, ) = ds.scorpionAddress.call{value: msg.value}(
                    ""
                );
                require(success, "refund failed");
            }
        } else {
            require(
                ds.usdtContract.allowance(msg.sender, address(this)) >=
                    amountInUSD,
                "ERC20: Must add allowance to this contract first."
            );
            if (_referredBy != address(0)) {
                refPart = (amountInUSD * ds.referral[code]) / ds.deno;
                scorpPart = amountInUSD - refPart;
                ds.usdtContract.safeTransferFrom(
                    msg.sender,
                    ds.scorpionAddress,
                    scorpPart
                );
                ds.usdtContract.safeTransferFrom(
                    msg.sender,
                    _referredBy,
                    refPart
                );
            } else {
                ds.usdtContract.safeTransferFrom(
                    msg.sender,
                    ds.scorpionAddress,
                    amountInUSD
                );
            }
        }

        ds.contribution[_contributionId] = TestLib.Contributors(
            _contributionId,
            amountInUSD,
            msg.sender,
            ds.currentPrice,
            code
        );

        if (ds.totalUserContribution[msg.sender] == 0)
            ds.firstTransact[msg.sender] = block.timestamp;
        ds.totalUserContribution[msg.sender] += amountInUSD;
        ds.totalContribution += amountInUSD;
        uint256 fixedAmount = amountInUSD / 10 ** 4;
        userTokens = (fixedAmount * ds.currentPrice) / 10 ** 2;
        if (ds.coupon[code] != 0) {
            ds.totalUserBonusTokens[msg.sender] +=
                (userTokens * ds.coupon[code]) /
                ds.deno;
        }
        ds.totalUserTokens[msg.sender] += userTokens;
        emit ContributeEvent(
            _contributionId,
            amountInUSD,
            msg.sender,
            ds.currentPrice,
            code
        );
    }
    function getLatestPrice() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (, int256 price, , uint256 timeStamp, ) = ds
            .priceFeed
            .latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return (uint256)(price) / 10 ** 6;
    }
}
