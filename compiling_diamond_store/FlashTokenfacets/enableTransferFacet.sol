// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract enableTransferFacet is ERC20, Ownable {
    function enableTransfer() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferEnabled = true;
    }
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.transferEnabled || msg.sender == owner(),
            "invalid transfer"
        );
        super._update(from, to, value);
    }
}
