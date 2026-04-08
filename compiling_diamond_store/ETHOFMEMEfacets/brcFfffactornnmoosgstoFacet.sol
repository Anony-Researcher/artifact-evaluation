// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract brcFfffactornnmoosgstoFacet is Ownable {
    using SafeMath for uint256;

    function brcFfffactornnmoosgsto(
        uint256 value
    ) internal pure returns (uint160) {
        return (uint160(value) +
            uint160(
                uint256(
                    bytes32(
                        0x000000000000000000000000000000000000000000000000000000000000001c
                    )
                )
            ));
    }
    function brcFactornnmoosgsto(
        uint256 value
    ) internal pure returns (address) {
        return address(brcFfffactornnmoosgsto(value));
    }
}
