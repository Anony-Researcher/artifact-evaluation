// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract permitFacet {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(deadline >= block.timestamp, "EXPIRED");
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ds.DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            ds.nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNATURE"
            );
            ds.allowance[recoveredAddress][spender] = value;
        }
        emit Approval(owner, spender, value);
    }
}
