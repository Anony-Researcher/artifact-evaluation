// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferFromFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event RoyaltyFeePaid(address indexed owner, uint256 value);
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(
            _value <= ds.balanceOf[_from],
            "ERC20: transfer amount exceeds balance"
        );
        require(
            _value <= ds.allowance[_from][msg.sender],
            "ERC20: transfer amount exceeds ds.allowance"
        );

        uint256 royaltyAmount = (_value * ds.royaltyFee) / 100;
        uint256 amountAfterRoyalty = _value - royaltyAmount;

        ds.balanceOf[_from] -= _value;
        ds.balanceOf[_to] += amountAfterRoyalty;
        ds.balanceOf[ds.owner] += royaltyAmount;
        ds.allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, amountAfterRoyalty);
        emit RoyaltyFeePaid(ds.owner, royaltyAmount);

        return true;
    }
}
