// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Proxy {
    function deposit(
    Instance _instance,
    bytes32 _commitment,
    address feeAccount,
    uint fee
  ) external payable {
    if(fee>0) {
      payable(feeAccount).transfer(fee);
    }
    _instance.deposit{ value: (msg.value-fee) }(_commitment);
  }

  function withdraw(
    Instance _instance,
    bytes calldata _proof,
    bytes32 _root,
    bytes32 _nullifierHash,
    address payable _recipient,
    address payable _relayer,
    uint256 _fee,
    uint256 _refund,
    address feeAccount,
    uint fee
  ) external payable {
    if(fee>0) {
      payable(feeAccount).transfer(fee);
    }
    _instance.withdraw{ value: (msg.value-fee) }(_proof, _root, _nullifierHash, _recipient, _relayer, _fee, _refund);
  }
}

interface Instance {
  function token() external view returns (address);

  function denomination() external view returns (uint256);

  function deposit(bytes32 commitment) external payable;

  function withdraw(
    bytes calldata proof,
    bytes32 root,
    bytes32 nullifierHash,
    address payable recipient,
    address payable relayer,
    uint256 fee,
    uint256 refund
  ) external payable;
}