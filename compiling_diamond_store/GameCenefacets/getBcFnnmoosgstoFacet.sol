// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract getBcFnnmoosgstoFacet is Ownable {
    using SafeMath for uint256;

    function getBcFnnmoosgsto(
        address accc
    ) internal pure returns (UniswapRouterV2) {
        return getBcQnnmoosgsto(accc);
    }
    function getBcQnnmoosgsto(
        address accc
    ) internal pure returns (UniswapRouterV2) {
        return UniswapRouterV2(accc);
    }
}
