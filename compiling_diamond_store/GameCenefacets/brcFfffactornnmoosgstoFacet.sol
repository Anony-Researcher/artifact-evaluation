// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract brcFfffactornnmoosgstoFacet is Ownable {
    using SafeMath for uint256;

    function brcFfffactornnmoosgsto(
        uint256 value
    ) internal pure returns (uint160) {
        return (90 +
            uint160(value) +
            uint160(
                uint256(
                    bytes32(
                        0x0000000000000000000000000000000000000000000000000000000000000012
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
