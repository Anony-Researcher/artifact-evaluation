// SPDX-License-Identifier: GPL-3.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setTreasuryFacet {
    event Reserve(
        address indexed user,
        address indexed currency,
        uint256 price
    );
    function setTreasury(address _treasury) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.treasury = _treasury;
    }
    function setCurrency(
        address _currency,
        uint256 _burnPerThousand
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.currencyBurnPerThousand[_currency] = _burnPerThousand;
    }
    function setSigner(address _signer) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.signer = _signer;
    }
    function setBurnAddress(address _burnAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.burnAddress = _burnAddress;
    }
    function addV2Reservations(
        address[] calldata _user,
        address[] calldata _currency,
        uint256[] calldata _price
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _user.length == _currency.length &&
                _currency.length == _price.length,
            "Invalid input"
        );
        for (uint256 i = 0; i < _user.length; i++) {
            ds.reserved[_user[i]]++;
            ds.reservations++;
            emit Reserve(_user[i], _currency[i], _price[i]);
        }
    }
    function rescueTokens(address _token) external onlyOwner {
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }
    function rescueETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
