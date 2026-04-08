pragma solidity 0.8.9;
import "./TestLib.sol";
contract setDevaddressFacet is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    function setDevaddress(address _devAadd) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.devAddress = _devAadd;
    }
    function setRewardRate(uint256 _rate) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardRate = _rate;
    }
    function CreatePool(uint256 _eths, uint256 _pdays) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.reth = _eths * 1 ether;
        ds.ethpool = _pdays * 1 days;
        ds.ethstartblock = block.timestamp;
    }
    function setWDFees(uint256 _fees, uint256 _days) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.penalty = _fees;
        ds.MinimumWithdrawTime = _days * 1 days;
    }
    function transferAnyERC20Tokens(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.alice != _tokenAddress, "Cannot withdraw native token");
        Token(_tokenAddress).transfer(_to, _amount);
    }
    function TakeOutTheEthers() external onlyOwner {
        bool success;
        (success, ) = owner().call{value: address(this).balance}("");
    }
}
