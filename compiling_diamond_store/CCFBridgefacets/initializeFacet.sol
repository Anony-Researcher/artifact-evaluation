// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract initializeFacet is OwnableUpgradeable {
    event Unlocked(
        address token,
        address indexed user,
        uint256 amount,
        uint256 blockchainIndex
    );
    function initialize(uint256 _contractBlockchainIndex) public initializer {
        __Ownable_init(msg.sender);

        updateProtocolFeePercentage(3000); //0.3%
        updateProtocolFeeDivider(1000000);
        updateContractBlockchainIndex(_contractBlockchainIndex);
    }
    function unlock(
        address _token,
        address user,
        uint256 amount,
        uint256 blockchainIndex
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tokenWhitelist[_token], "Token not whitelisted");
        require(
            ds.lockedBalance[_token] >= amount,
            "Insufficient locked balance"
        );
        require(IERC20Token(_token).transfer(user, amount), "Transfer failed");
        ds.lockedBalance[_token] -= amount;

        emit Unlocked(_token, user, amount, blockchainIndex);
    }
    function updateMinimumFee(
        uint256 blockchainIndex,
        uint256 fee
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimumFees[blockchainIndex] = fee;
    }
    function updateMinimumFeesBatch(
        uint256[] memory blockchainIndexes,
        uint256[] memory fees
    ) external onlyOwner {
        require(
            blockchainIndexes.length == fees.length,
            "Lengths of arrays do not match"
        );

        for (uint256 i = 0; i < blockchainIndexes.length; i++) {
            updateMinimumFee(blockchainIndexes[i], fees[i]);
        }
    }
    function updateProtocolFeePercentage(
        uint256 _protocolFeePercentage
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.protocolFeePercentage = _protocolFeePercentage;
    }
    function updateContractBlockchainIndex(
        uint256 _contractBlockchainIndex
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.contractBlockchainIndex = _contractBlockchainIndex;
    }
    function updateProtocolFeeDivider(
        uint256 _protocolFeeDivider
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.protocolFeeDivider = _protocolFeeDivider;
    }
    function withdrawProtocolFees(
        address _token,
        address receiver,
        uint256 amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.totalProtocolFees[_token] >= amount,
            "Insufficient protocolFee balance"
        );
        require(
            IERC20Token(_token).transfer(receiver, amount),
            "Transfer failed"
        );
        ds.totalProtocolFees[_token] -= amount;
    }
    function withdrawBridgeFees(
        address _token,
        address receiver,
        uint256 amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.totalBridgeFees[_token] >= amount,
            "Insufficient bridgeFee balance"
        );
        require(
            IERC20Token(_token).transfer(receiver, amount),
            "Transfer failed"
        );
        ds.totalBridgeFees[_token] -= amount;
    }
    function addToWhitelist(address _token) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tokenWhitelist[_token] = true;
    }
    function removeFromWhitelist(address _token) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tokenWhitelist[_token] = false;
    }
}
