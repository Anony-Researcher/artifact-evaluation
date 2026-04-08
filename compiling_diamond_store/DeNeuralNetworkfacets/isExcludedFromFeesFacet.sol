/*
//DENEURAL NETWORK

//WEB:  https://deneuralnetwork.com
//TG:   https://t.me/DENEURALNETWORK_portal
//TW:   https://twitter.com/DENEURALNETWORK
//GIT:  https://whitepaper.deneuralnetwork.com/
//DAPP: https://t.me/DeNeuralNetworkbot
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
