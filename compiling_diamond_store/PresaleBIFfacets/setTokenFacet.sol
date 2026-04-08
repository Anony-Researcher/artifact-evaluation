// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract setTokenFacet is Ownable {
    using SafeMath for uint256;

    event SetCurrentStage(uint256 stage);
    event SetIStake(IStake stake);
    event SetInSell(bool _inSell);
    event SetInClaim(bool _inClaimed);
    event SetInStake(bool _inStake);
    event SetPriceByUSD(uint256 stage, uint256 newPrice);
    event SetUSDTToken(USDTInterface tokenAddress);
    event Claim(address buyer, uint256 amount);
    function setToken(IERC20 _token) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.token = _token;
    }
    function setCurrentStage(uint256 stage) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.currentStage = stage;
        emit SetCurrentStage(stage);
    }
    function setAggregatorETHInterface(
        address _aggregatorETHInterface
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.aggregatorETHInterface = AggregatorV3Interface(
            _aggregatorETHInterface
        );
    }
    function setAggregatorUSDTInterface(
        address _aggregatorUSDTInterface
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.aggregatorUSDTInterface = AggregatorV3Interface(
            _aggregatorUSDTInterface
        );
    }
    function setRefPercent(uint256 newPercent) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.refPercent = newPercent;
    }
    function setStageInfo(
        uint256 stageId,
        uint256 _totalRaise,
        uint256 _raised,
        uint256 _priceInUSDStage
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stages[stageId] = TestLib.Stage(
            _totalRaise,
            _raised,
            _priceInUSDStage
        );
    }
    function setStakeContract(IStake _stake) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stake = _stake;
        emit SetIStake(_stake);
    }
    function setInSell(bool _inSell) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSell = _inSell;
        emit SetInSell(_inSell);
    }
    function setInClaim(bool _inClaim) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inClaim = _inClaim;
        emit SetInClaim(_inClaim);
    }
    function setInStake(bool _inStake) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inStake = _inStake;
        emit SetInStake(_inStake);
    }
    function setInRefReward(bool _inRefReward) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inRefReward = _inRefReward;
    }
    function setPriceByUSD(uint256 stage, uint256 newPrice) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stages[stage].priceInUSDStage = newPrice;
        emit SetPriceByUSD(stage, newPrice);
    }
    function setDecimalsToken(uint256 _decimals) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.decimals_token = _decimals;
    }
    function setDecimalsUSDT(uint256 _decimals) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.decimals_usdt = _decimals;
    }
    function setTotalRaise(
        uint256 stage,
        uint256 _totalRaise
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stages[stage].totalRaise = _totalRaise;
    }
    function setUSDTToken(USDTInterface token_address) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.usdtToken = token_address;
        emit SetUSDTToken(token_address);
    }
    function setWallet(address payable wallet) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._wallet = wallet;
    }
    function withdraw() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.token.transfer(ds._walletToken, ds.token.balanceOf(address(this)));
    }
    function withdrawRef() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.usdtToken.transfer(
            ds._wallet,
            ds.usdtToken.balanceOf(address(this))
        );
    }
    function balanceOf(address account) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.buyers[account];
    }
    function claim() public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.inClaim, "Invalid time for claim");
        uint256 amount = ds.buyers[msg.sender];
        require(amount > 0, "You not have ds.token to claim");
        require(
            ds.token.balanceOf(address(this)) > amount,
            "Not enought ds.token to send to you"
        );
        bool success = ds.token.transfer(msg.sender, amount);
        require(success, "Transfer ds.token error");
        ds.buyers[msg.sender] = ds.buyers[msg.sender].sub(
            amount,
            "transfer from ds.buyers to wallet error"
        );
        ds.claimers[msg.sender] = ds.claimers[msg.sender].add(amount);
        ds.totalClaimed = ds.totalClaimed.add(amount);
        emit Claim(msg.sender, amount);
        return success;
    }
}
