// File: @openzeppelin/contracts/utils/Nonces.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract pauseFacet is ERC20, ERC20Pausable {
    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }
    function mint(address to, uint256 amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            totalSupply() + amount <= ds.maxSupply,
            "ds.maxSupply exceeded"
        );
        _mint(to, amount);
    }
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
