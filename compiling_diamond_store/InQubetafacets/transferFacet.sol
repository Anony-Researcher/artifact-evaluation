// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract transferFacet is ERC20, AccessControl {
    modifier checkMaxFee(uint256 _buyFee, uint256 _sellFee) {
        if (_buyFee >= PRECISION || _sellFee >= PRECISION) {
            revert HighValue("InQubeta: Fee value is too high");
        }
        _;
    }

    event AddPair(
        address indexed addressPair,
        bool enabled,
        uint256 indexed timestamp
    );
    event RemovePair(
        address indexed addressPair,
        bool disable,
        uint256 indexed timestamp
    );
    event DisableFees(bool indexed enabled, uint256 indexed timestamp);
    event EnableFees(bool indexed enabled, uint256 indexed timestamp);
    event UpdateBuyFee(uint256 buyFee, uint256 indexed timestamp);
    event UpdateSellFee(uint256 buyFee, uint256 indexed timestamp);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 indexed timestamp);
    event UpdateFeeCollector(
        address indexed feeCollector,
        uint256 indexed timestamp
    );
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        return _transferFrom(msg.sender, to, amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        return _transferFrom(from, to, amount);
    }
    function addPair(
        address addressPair
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (addressPair == address(0)) {
            revert ZeroAddress("InQubeta: Zero address");
        }

        if (ds.pairs[addressPair]) {
            revert ExistsAddress("InQubeta: Address already exists");
        }

        ds.pairs[addressPair] = true;
        emit AddPair(addressPair, true, block.timestamp);
    }
    function removePair(
        address addressPair
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (addressPair == address(0)) {
            revert ZeroAddress("InQubeta: Zero address");
        }

        ds.pairs[addressPair] = false;
        emit RemovePair(addressPair, false, block.timestamp);
    }
    function disableFees() external onlyRole(FEE_DISTRIBUTION_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isEnabledFees = false;
        emit DisableFees(false, block.timestamp);
    }
    function enableFees() external onlyRole(FEE_DISTRIBUTION_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isEnabledFees = true;
        emit EnableFees(true, block.timestamp);
    }
    function updateBuyFee(
        uint256 _buyFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_buyFee >= PRECISION) {
            revert HighValue("InQubeta: Fee value is too high");
        }

        ds.buyFee = _buyFee;
        emit UpdateBuyFee(_buyFee, block.timestamp);
    }
    function updateSellFee(
        uint256 _sellFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_sellFee >= PRECISION) {
            revert HighValue("InQubeta: Fee value is too high");
        }

        ds.sellFee = _sellFee;
        emit UpdateSellFee(_sellFee, block.timestamp);
    }
    function updateFeesPercents(
        uint256 _buyFee,
        uint256 _sellFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) checkMaxFee(_buyFee, _sellFee) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyFee = _buyFee;
        ds.sellFee = _sellFee;

        emit SetFees(_buyFee, _sellFee, block.timestamp);
    }
    function updateFeeCollector(
        address newFeeCollector
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (newFeeCollector == address(0)) {
            revert ZeroAddress("InQubeta: Zero address");
        }
        if (newFeeCollector == ds.feeCollector) {
            revert ExistsAddress("InQubeta: No new address specified");
        }
        if (!Address.isContract(newFeeCollector)) {
            revert IsNotContract("InQubeta: Fee collector is not a contract");
        }
        revokeRole(FEE_DISTRIBUTION_ROLE, ds.feeCollector);
        ds.feeCollector = newFeeCollector;
        grantRole(FEE_DISTRIBUTION_ROLE, newFeeCollector);

        emit UpdateFeeCollector(newFeeCollector, block.timestamp);
    }
    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isEnabledFees) {
            if (ds.pairs[to]) {
                uint256 fee = (amount * ds.sellFee) / PRECISION;
                uint256 transferAmount = amount - fee;
                _transfer(from, ds.feeCollector, fee);
                _transfer(from, to, transferAmount);
                IFeeCollector(ds.feeCollector).recordSellFee(fee);
            } else if (ds.pairs[from]) {
                uint256 fee = (amount * ds.buyFee) / PRECISION;
                _transfer(from, to, amount);
                _transfer(to, ds.feeCollector, fee);
                IFeeCollector(ds.feeCollector).recordBuyFee(fee);
            } else {
                _transfer(from, to, amount);
            }
        } else {
            _transfer(from, to, amount);
        }
        return true;
    }
}
