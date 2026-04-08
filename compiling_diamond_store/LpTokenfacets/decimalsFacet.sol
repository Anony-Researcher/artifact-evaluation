// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;
import "./TestLib.sol";
contract decimalsFacet is ERC20, ILpToken {
    modifier onlyMinter() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.minter, "not authorized");
        _;
    }

    function decimals()
        public
        view
        virtual
        override(ERC20, IERC20Metadata)
        returns (uint8)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.__decimals;
    }
    function mint(
        address _account,
        uint256 _amount,
        address ubo
    ) external override onlyMinter returns (uint256) {
        _ensureSingleEvent(ubo, _amount);
        _mint(_account, _amount);
        return _amount;
    }
    function burn(
        address _owner,
        uint256 _amount,
        address ubo
    ) external override onlyMinter returns (uint256) {
        _ensureSingleEvent(ubo, _amount);
        _burn(_owner, _amount);
        return _amount;
    }
    function taint(address from, address to, uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == address(ds.controller.lpTokenStaker()),
            "not authorized"
        );
        _taint(from, to, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // mint/burn are handled in their respective functions
        if (from == address(0) || to == address(0)) return;

        // lpTokenStaker calls `taint` as needed
        address lpTokenStaker = address(ds.controller.lpTokenStaker());
        if (from == lpTokenStaker || to == lpTokenStaker) return;

        // taint any other type of transfer
        _taint(from, to, amount);
    }
    function _taint(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            from != to &&
            ds._lastEvent[from] == block.number &&
            amount >
            ds.controller.getMinimumTaintedTransferAmount(address(this))
        ) {
            ds._lastEvent[to] = block.number;
        }
    }
    function _ensureSingleEvent(address ubo, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            !ds.controller.isAllowedMultipleDepositsWithdraws(ubo) &&
            amount >
            ds.controller.getMinimumTaintedTransferAmount(address(this))
        ) {
            require(
                ds._lastEvent[ubo] != block.number,
                "cannot mint/burn twice in a block"
            );
            ds._lastEvent[ubo] = block.number;
        }
    }
}
