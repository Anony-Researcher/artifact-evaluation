// SPDX-License-Identifier: GPL-3.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract formMessageFacet {
    function formMessage(
        address _user,
        address _currency,
        uint256 _unitPrice,
        uint256 _deadline
    ) external view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    _user,
                    _currency,
                    _unitPrice,
                    _deadline
                )
            );
    }
}
