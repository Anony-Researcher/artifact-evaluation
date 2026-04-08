/*
 * SPDX-License-Identifier: MIT
 * https://hobbestoken.vip
 * https://twitter.com/HobbesOnEth
 * https://t.me/Hobbes_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract feeReceiverAddressesFacet is ERC20 {
    using SafeMath for uint256;

    function feeReceiverAddresses()
        external
        view
        returns (address _mktReceiver, address _devReceiver)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds.mktReceiver, ds.devReceiver);
    }
}
