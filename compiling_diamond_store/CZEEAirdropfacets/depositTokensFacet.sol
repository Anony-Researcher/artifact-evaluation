// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract depositTokensFacet {
    function depositTokens(address _token, uint256 _amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.token = IERC20(_token);
        ds.token.transferFrom(msg.sender, address(this), _amount);

        ds.maxAirdropsAmount += _amount;
    }
    function startAirdrop(
        uint256 _airdropDeadline,
        uint256 _airdropPerAccountAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isStarted, "Airdrop has been started already!");
        require(
            ds.maxAirdropsAmount > 0,
            "Add tokens to the contract, before starting the Airdrop"
        );

        ds.airdropDuration = _airdropDeadline * 1 days;
        ds.airdropPerAccountAmount = _airdropPerAccountAmount;

        ds.airdropStartTime = block.timestamp;
        ds.airdropEndTime = ds.airdropStartTime + ds.airdropDuration;

        ds.isStarted = true;
        ds.remainigAirdropAmount = ds.maxAirdropsAmount;
    }
    function sendAirdrops(address[] memory acs) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isStarted, "Airdrop hasn't started yet!");

        for (uint i; i < acs.length; i++) {
            address acc = acs[i];
            // If the account isn't already on the airdrop list!
            if (!ds.isInAirdropList[acc]) sendAirdropToAcc(acc);
        }
    }
    function withdrawTokens(uint amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount <= getAirdripTokensBalance(), "Not enough ds.token");
        ds.token.transfer(msg.sender, amount);
    }
    function getAirdripTokensBalance() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.token.balanceOf(address(this));
    }
    function sendAirdropToAcc(address acc) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.releasedAirdropAmount < ds.maxAirdropsAmount);
        require(
            ds.remainigAirdropAmount >= ds.airdropPerAccountAmount,
            "Not enough tokens for airdrop"
        );

        ds.token.transfer(acc, ds.airdropPerAccountAmount);

        ds.isInAirdropList[acc] = true;
        ds.remainigAirdropAmount -= ds.airdropPerAccountAmount;
        ds.releasedAirdropAmount += ds.airdropPerAccountAmount;
    }
}
