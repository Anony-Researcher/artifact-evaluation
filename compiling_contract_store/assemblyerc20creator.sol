// SPDX-License-Identifier: MIT
// Telegram: https://t.me/AssemblyERC20Portal
// Twitter: https://twitter.com/AssemblyERC20
pragma solidity 0.8.25;

contract assemblyerc20creator {
    event Deployed(address addr, uint256 salt);

    function deploy(bytes memory code, uint256 salt) public {
        address addr;
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, salt);
    }

    // Oluşturulacak adresi hesapla
    function calculateAddress(bytes memory code, uint256 salt) public view returns (address) {
        bytes32 codeHash = keccak256(code);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, codeHash));
        return address(uint160(uint256(hash)));
    }
}