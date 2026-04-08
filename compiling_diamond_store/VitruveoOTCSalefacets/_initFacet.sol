// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract _initFacet is AccessControl {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    function _init() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isSaleActive = true;

        ds.minPerTx = 10 * 1e18;
        ds.maxPerTx = 100000 * 1e18;

        ds.vtruOTCPrice = 250;

        ds.TokenDecimals["USDT"] = 6;
        ds.TokenDecimals["USDC"] = 6;

        ds.OTCStatus[1] = "pending";
        ds.OTCStatus[2] = "completed";
        ds.OTCStatus[3] = "cancelled";

        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        //Vitruveo Multisig - Ethereum
        ds.vtruWallet1 = 0x725A4b6be3dC89f1C503977FA2E414E6243eAb8d;
        ds.vtruWallet2 = 0xd9FcA2461c80342c18ad77446c1badcD87f4Fe9d;
        ds.vtruWallet3 = 0xFA931ccfe2274c8c4253A11F3c5561611531A070;
        ds.vtruWallet4 = 0x6672AaFc4f1EA7339115cECc1B960F93be1F9925;
        ds.vtruWallet5 = 0x1effF2019cF250975FA7394f694240cf62288506;
        ds.vtruWallet6 = 0x1c5d6923557319907d65994c245b5408740E5805;
        ds.vtruWallet7 = 0x113CE0e883a54Fc875626E195f053498F37B9E74;
        ds.vtruWallet8 = 0x54052055f3656Fb40efdbB998e99403ec6f1E4EE;

        setAllowedTokens("USDC", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        setAllowedTokens("USDT", 0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }
    function setAllowedTokens(
        string memory _symbol,
        address _tokenAddress
    ) public onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.AllowedTokens[_symbol] = _tokenAddress;
    }
    function buyVTRUViaOTC(
        string memory symbol,
        uint256 qty,
        uint256 amount,
        uint256 vam,
        uint256 vamBonus
    ) external nonReentrant returns (TestLib.otcDetails memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalQuantity = qty + vamBonus;

        require(ds.isSaleActive == true, "Sale not active");
        require(
            qty >= ds.minPerTx && qty <= ds.maxPerTx,
            "Qty must be greater than ds.minPerTx & less than ds.maxPerTx"
        );
        require(
            ds.AllowedTokens[symbol] != address(0),
            "Address not part of allowed token list"
        );

        ds.nextSaleId.increment();
        address tokenAddress = ds.AllowedTokens[symbol];
        ds.ERC20Deposit[msg.sender][tokenAddress] += amount;
        ds.AccountDeposits[msg.sender][symbol].push(ds.nextSaleId.current());

        ds.totalSaleCounter = ds.totalSaleCounter + amount;
        ds.TotalTokenSaleCounter[symbol] =
            ds.TotalTokenSaleCounter[symbol] +
            amount;

        TestLib.otcDetails memory newOTCSale = _createNewOTCSale(
            symbol,
            totalQuantity,
            amount,
            msg.sender,
            vam,
            vamBonus,
            block.timestamp,
            ds.OTCStatus[2]
        );

        _splitPayment(tokenAddress, amount);

        emit ERC20Deposited(
            newOTCSale.id,
            symbol,
            msg.sender,
            totalQuantity,
            amount
        );

        return newOTCSale;
    }
    function _createNewOTCSale(
        string memory _symbol,
        uint256 _qty,
        uint256 _amount,
        address _account,
        uint256 _vam,
        uint256 _vamBonus,
        uint256 _timestamp,
        string memory _status
    ) internal returns (TestLib.otcDetails memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.otcDetails storage newOTCSale = ds.OTCDetails[
            ds.nextSaleId.current()
        ];
        newOTCSale.id = ds.nextSaleId.current();
        newOTCSale.tokenSymbol = _symbol;
        newOTCSale.qty = _qty;
        newOTCSale.tokenAmount = _amount;
        newOTCSale.accountAddress = _account;
        newOTCSale.vam = _vam;
        newOTCSale.vamBonus = _vamBonus;
        newOTCSale.price = ds.vtruOTCPrice;
        newOTCSale.timestamp = _timestamp;
        newOTCSale.status = _status;

        return newOTCSale;
    }
    function _splitPayment(address tokenAddress, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Calculate the amounts for each wallet
        uint256 amountWallet1 = (amount * 125) / 10000; // 1.25%
        uint256 amountWallet2 = (amount * 125) / 10000; // 1.25%
        uint256 amountWallet3 = (amount * 5) / 100; // 5%
        uint256 amountWallet4 = (amount * 5) / 100; // 5%
        uint256 amountWallet5 = (amount * 10) / 100; // 10%
        uint256 amountWallet6 = (amount * 175) / 1000; // 17.5%
        uint256 amountWallet7 = (amount * 30) / 100; // 30%
        uint256 amountWallet8 = (amount * 30) / 100; // 30%

        // Transfer tokens to each wallet
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet1,
            amountWallet1
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet2,
            amountWallet2
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet3,
            amountWallet3
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet4,
            amountWallet4
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet5,
            amountWallet5
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet6,
            amountWallet6
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet7,
            amountWallet7
        );
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            ds.vtruWallet8,
            amountWallet8
        );
    }
    function setTokenDecimals(
        string memory _symbol,
        uint256 _decimals
    ) public onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.TokenDecimals[_symbol] = _decimals;
    }
    function setSaleStatus(bool _isActive) external onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isSaleActive = _isActive;
    }
    function setVTRUWallet(
        address _vtruWallet1,
        address _vtruWallet2,
        address _vtruWallet3,
        address _vtruWallet4,
        address _vtruWallet5,
        address _vtruWallet6,
        address _vtruWallet7,
        address _vtruWallet8
    ) external onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.vtruWallet1 = _vtruWallet1;
        ds.vtruWallet2 = _vtruWallet2;
        ds.vtruWallet3 = _vtruWallet3;
        ds.vtruWallet4 = _vtruWallet4;
        ds.vtruWallet5 = _vtruWallet5;
        ds.vtruWallet6 = _vtruWallet6;
        ds.vtruWallet7 = _vtruWallet7;
        ds.vtruWallet8 = _vtruWallet8;
    }
    function setMinPerTx(uint256 _minPerTx) external onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minPerTx = _minPerTx;
    }
    function setMaxPerTx(uint256 _maxPerTx) external onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxPerTx = _maxPerTx;
    }
    function setPrice(uint256 _vtruOTCPrice) external onlyRole(ADMIN_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.vtruOTCPrice = _vtruOTCPrice;
    }
    function withdraw() external onlyRole(ADMIN_ROLE) {
        require(payable(msg.sender).send(address(this).balance));
    }
    function recoverERC20(
        IERC20 tokenContract,
        address to
    ) external onlyRole(ADMIN_ROLE) {
        tokenContract.transfer(to, tokenContract.balanceOf(address(this)));
    }
}
