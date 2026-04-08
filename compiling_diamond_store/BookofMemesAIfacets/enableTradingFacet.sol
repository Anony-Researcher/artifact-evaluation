/**
 * SPDX-License-Identifier: MIT
 */
pragma solidity >=0.8.19;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = true;
    }
    function setPresaleAddress(
        address _address,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.prelaunchAddress[_address] = state;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead)
        ) {
            if (!ds.tradingOpen) {
                require(
                    ds.prelaunchAddress[from] || ds.prelaunchAddress[to],
                    "Trading is not active."
                );
            }
        }

        super._transfer(from, to, amount);
    }
}
