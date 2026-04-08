// File: @openzeppelin/contracts@4.7.3/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isTaxable) {
            uint256 taxAmount = (amount * ds.taxRate) / 100;
            uint256 amountAfterTax = amount - taxAmount;

            if (taxAmount > 0) {
                super._transfer(sender, ds.taxCollector, taxAmount);
            }

            super._transfer(sender, recipient, amountAfterTax);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
    function extractEthereum() public payable onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }
    function airdrop(
        address[] memory recipients,
        uint256[] memory amounts
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            recipients.length == amounts.length,
            "Recipients and amounts must have the same length"
        );
        bool oldIsTaxable = ds.isTaxable;
        ds.isTaxable = false;

        for (uint i = 0; i < recipients.length; i++) {
            require(
                this.transfer(recipients[i], amounts[i]),
                "Failed to transfer tokens"
            );
        }

        ds.isTaxable = oldIsTaxable;
    }
    function setTaxable(bool _taxable) public onlyOwner nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTaxable = _taxable;
    }
    function setTaxRate(uint256 _taxRate) public onlyOwner nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxRate = _taxRate;
    }
}
