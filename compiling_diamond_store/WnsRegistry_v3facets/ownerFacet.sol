// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract ownerFacet {
    function owner() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.wnsAddresses.owner();
    }
    function setRegistry_v1(address _registry) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == owner(), "Not authorized.");
        ds.WnsRegistry_v1 = _registry;
        ds.wnsRegistry_v1 = WnsRegistryInterface(ds.WnsRegistry_v1);
    }
    function setAddresses(address addresses_) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == owner(), "Not authorized.");
        ds.WnsAddresses = addresses_;
        ds.wnsAddresses = WnsAddressesInterface(ds.WnsAddresses);
    }
}
