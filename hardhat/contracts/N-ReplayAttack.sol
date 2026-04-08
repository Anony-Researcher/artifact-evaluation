//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Address.sol";

contract MultiSig {
  using Address for address payable;
  address[2] public owners;

  struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  constructor(address[2] memory _owners) {
         owners = _owners;
  }

  function transfer(
    address to,
    uint256 amount,
    Signature[2] memory signatures
  ) external {
           require(verifySignature(to, amount, signatures[0]) == owners[0]);
           require(verifySignature(to, amount, signatures[1]) == owners[1]);

           payable(to).sendValue(amount);
  }

  function verifySignature(
    address to,
    uint256 amount,
    Signature memory signature
  ) public pure returns (address signer) {
         // 52 = message length
          string memory header = "\x19Ethereum Signed Message:\n52";

    // Perform the elliptic curve recover operation
          bytes32 messageHash = keccak256(abi.encodePacked(header, to, amount));

         return ecrecover(messageHash, signature.v, signature.r, signature.s);
  }

  receive() external payable {}
}