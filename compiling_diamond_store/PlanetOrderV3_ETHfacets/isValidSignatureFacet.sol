// SPDX-License-Identifier: GPL-3.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract isValidSignatureFacet {
    event Reserve(
        address indexed user,
        address indexed currency,
        uint256 price
    );
    function isValidSignature(
        address _user,
        address _currency,
        uint256 _unitPrice,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bytes memory packedHash = abi.encodePacked(
            address(this),
            _user,
            _currency,
            _unitPrice,
            _deadline
        );
        bytes32 hash = keccak256(packedHash);
        bytes memory packedString = abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            hash
        );
        return ecrecover(keccak256(packedString), _v, _r, _s) == ds.signer;
    }
    function reserve(
        address _currency,
        uint256 _price,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            isValidSignature(
                msg.sender,
                _currency,
                _price,
                _deadline,
                _v,
                _r,
                _s
            ),
            "Invalid permit"
        );
        uint256 burnAmount = (_price * ds.currencyBurnPerThousand[_currency]) /
            1000;

        if (_currency == WETH && msg.value > 0) {
            // Minting with WETH
            // Amount of WETH sent must be correct
            require(msg.value >= _price, "Transaction underpriced");

            if (burnAmount > 0) {
                // Burn some WETH
                payable(ds.burnAddress).transfer(burnAmount);
            }

            // Pay to ds.treasury
            payable(ds.treasury).transfer(msg.value - burnAmount);
        } else {
            // Transfer the tokens
            if (burnAmount > 0) {
                IERC20(_currency).transferFrom(
                    msg.sender,
                    ds.burnAddress,
                    burnAmount
                );
            }

            IERC20(_currency).transferFrom(
                msg.sender,
                address(this),
                _price - burnAmount
            );

            // Check if the tokens were transferred
            uint256 newBalance = IERC20(_currency).balanceOf(address(this));
            require(newBalance > 0, "Cannot transfer tokens");

            IERC20(_currency).transfer(ds.treasury, newBalance);
        }

        emit Reserve(msg.sender, _currency, _price);
        ds.reserved[msg.sender]++;
        ds.reservations++;
    }
}
