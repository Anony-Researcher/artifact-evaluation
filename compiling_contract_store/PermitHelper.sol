// SPDX-License-Identifier: Apache 2.0

pragma solidity 0.8.4;


/*

   Copyright Tether.to 2023

   Version 2.0(a)

   Licensed under the Apache License, Version 2.0
   http://www.apache.org/licenses/LICENSE-2.0


*/
interface IPermit {
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

contract PermitHelper {
    function permit(IPermit recipient, address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        recipient.permit(owner, spender, amount, deadline, v, r, s);
    }
}