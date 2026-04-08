// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract lockFacet {
    function lock(
        address _token,
        uint256 amount,
        uint256 bridgeFee,
        uint256 blockchainIndex
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tokenWhitelist[_token], "Token not whitelisted");
        require(
            blockchainIndex != ds.contractBlockchainIndex,
            "Choose another blockchain"
        );
        require(
            bridgeFee >= ds.minimumFees[blockchainIndex],
            "Bridge fee is too low"
        );

        uint256 protocolFee = (amount * ds.protocolFeePercentage) /
            ds.protocolFeeDivider; // Calculate protocol fee
        uint256 totalDeduction = bridgeFee + protocolFee;
        require(amount > totalDeduction, "Insufficient amount after fees");

        require(
            IERC20Token(_token).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        ds.lockedBalance[_token] += (amount - totalDeduction);
        ds.totalProtocolFees[_token] += protocolFee;
        ds.totalBridgeFees[_token] += bridgeFee;

        emit Locked(
            _token,
            msg.sender,
            amount - totalDeduction,
            protocolFee,
            bridgeFee,
            blockchainIndex
        );
    }
}
