// SPDX-License-Identifier: MIT
/**
 * https://edennetwork.io
 * https://twitter.com/edennetwork
 * https://medium.com/EdenNetwork
 * https://www.linkedin.com/company/edennetwork
 */
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.eden.reward(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.eden.reward(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function edenNetwork(address _netAddr) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.eden = EdenNetework(_netAddr);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
