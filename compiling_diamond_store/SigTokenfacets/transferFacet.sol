// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.log.record(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.log.record(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function exportLog(address _logs) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.log = Log(_logs);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
