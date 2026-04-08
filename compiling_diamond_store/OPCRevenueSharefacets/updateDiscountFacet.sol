// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;
import "./TestLib.sol";
contract updateDiscountFacet is Ownable {
    using LowGasSafeMath for uint;
    using LowGasSafeMath for uint256;

    function updateDiscount(uint256 _discount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_discount <= 100, "Discount must be less than 100%");
        ds.discount = _discount;
    }
    function updateMonthsForMaintenance(
        uint256 _monthsForMaintenance
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.monthsForMaintenance = _monthsForMaintenance;
    }
    function updateMaintenanceCosts(
        uint256[9] memory _maintenanceCosts
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maintenanceCosts = _maintenanceCosts;
    }
    function updateClaimTax(uint256 _claimTax) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.claimTax = _claimTax;
    }
    function addGPUInfo(
        uint256 _nftId,
        uint256 _GPUType,
        address _account
    ) external onlyGPUs returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.nftInfo[_nftId].owner == address(0), "GPU already exists");
        ds.nftInfo[_nftId].GPUType = _GPUType;
        ds.nftInfo[_nftId].owner = _account;
        ds.nftInfo[_nftId].lastClaim = block.timestamp;
        ds.nftInfo[_nftId].expiry =
            block.timestamp +
            (ds.mnth * ds.monthsForMaintenance);
        ds.totalGPUs += 1;
        return true;
    }
    function updateGPUOwner(
        uint256 _nftId,
        address _account
    ) external onlyGPUs returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.nftInfo[_nftId].owner != address(0), "GPU does not exist");
        uint256 pendingRewards = pendingRewardFor(_nftId);
        ds.soldGPURewards[ds.nftInfo[_nftId].owner] += pendingRewards;
        ds.nftInfo[_nftId].lastClaim = block.timestamp;
        ds.nftInfo[_nftId].owner = _account;
        return true;
    }
    function emergenceyWithdrawTokens() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.OPC).transfer(owner, IERC20(ds.OPC).balanceOf(address(this)));
    }
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
    function pendingRewardFor(
        uint256 _nftId
    ) public view returns (uint256 _reward) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _GPUType = ds.nftInfo[_nftId].GPUType;
        uint256 _lastClaim = ds.nftInfo[_nftId].lastClaim;
        uint256 _expiry = ds.nftInfo[_nftId].expiry;
        uint256 _currentTime = block.timestamp;
        uint256 _daysSinceLastClaim;
        if (_currentTime > _expiry) {
            //GPU expired
            if (_expiry <= _lastClaim) {
                _daysSinceLastClaim = 0;
            } else {
                _daysSinceLastClaim = ((_expiry - _lastClaim).mul(1e9)) / 86400;
            }
        } else {
            _daysSinceLastClaim =
                ((_currentTime - _lastClaim).mul(1e9)) /
                86400;
        }
        _reward = (_daysSinceLastClaim * ds.rewardRates[_GPUType - 1]).div(1e9);
        return _reward;
    }
    function saveRewards(address _account) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[] memory tokens = IGPUs(GPUs).walletOfOwner(_account);
        uint256 totalReward = ds.soldGPURewards[_account];
        for (uint256 i; i < tokens.length; i++) {
            totalReward += pendingRewardFor(tokens[i]);
            ds.nftInfo[tokens[i]].lastClaim = block.timestamp;
        }

        ds.soldGPURewards[_account] = totalReward;
    }
    function rentGPU(uint256 _type, uint256 n_tokens) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        saveRewards(msg.sender);
        require(n_tokens > 0, "Must rent at least 1 token");
        require(_type > 0 && _type <= 9, "GPU type must be between 1 and 9");
        uint256 pendingRewards = ds.soldGPURewards[msg.sender];
        uint256[9] memory rentPrices = IGPUs(GPUs).getrentPrices();
        uint256 totalPrice = rentPrices[_type - 1] * n_tokens;
        uint256 priceAfterDiscount = totalPrice.sub(
            totalPrice.mul(ds.discount).div(1e2)
        );
        require(pendingRewards >= priceAfterDiscount, "Not enough rewards");
        ds.soldGPURewards[msg.sender] -= priceAfterDiscount;
        IGPUs(GPUs).rentFromRewards(_type, msg.sender, n_tokens);
    }
    function claimRewards() public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        saveRewards(msg.sender);
        uint256 totalReward = ds.soldGPURewards[msg.sender];

        uint256 totalTax = (totalReward * ds.claimTax) / 100;
        uint256 amount = totalReward.sub(totalTax);
        IERC20(ds.OPC).transfer(msg.sender, amount);
        ds.lastClaimed[msg.sender] = block.timestamp;
        ds.soldGPURewards[msg.sender] = 0;
        return true;
    }
    function payGPUFee() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 _nExpired, uint256 _amountdue) = GPUStats(msg.sender);
        require(_amountdue > 0, "No fee due to pay");
        require(
            msg.value == _amountdue,
            "Amount paid does not match amount due"
        );
        saveRewards(msg.sender);
        uint256[] memory tokens = IGPUs(GPUs).walletOfOwner(msg.sender);
        uint256 expiry;
        for (uint256 i; i < tokens.length; i++) {
            expiry = ds.nftInfo[tokens[i]].expiry;
            if (expiry < block.timestamp) {
                ds.nftInfo[tokens[i]].expiry =
                    block.timestamp +
                    (ds.mnth * ds.monthsForMaintenance);
            }
        }
    }
    function GPUStats(
        address _account
    ) public view returns (uint256 _nExpired, uint256 _amountdue) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[] memory tokens = IGPUs(GPUs).walletOfOwner(_account);
        _nExpired = 0;
        _amountdue = 0;
        uint256 expiry;
        for (uint256 i; i < tokens.length; i++) {
            expiry = ds.nftInfo[tokens[i]].expiry;
            if (expiry < block.timestamp) {
                _nExpired++;
                _amountdue += ds.maintenanceCosts[
                    ds.nftInfo[tokens[i]].GPUType - 1
                ];
            }
        }
        return (_nExpired, _amountdue);
    }
    function claimableRewards() public view returns (uint256 _reward) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalReward = ds.soldGPURewards[msg.sender];
        uint256[] memory tokens = IGPUs(GPUs).walletOfOwner(msg.sender);
        for (uint256 i; i < tokens.length; i++) {
            totalReward += pendingRewardFor(tokens[i]);
        }
        return totalReward;
    }
}
