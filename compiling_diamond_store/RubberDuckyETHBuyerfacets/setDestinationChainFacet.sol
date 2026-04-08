//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract setDestinationChainFacet is Ownable, AxelarExecutable {
    function setDestinationChain(
        string calldata destinationChain_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.destinationChain = destinationChain_;
    }
    function setDestinationAddress(
        string calldata destinationAddress_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.destinationAddress = destinationAddress_;
    }
    function setMinGas(uint256 minGas_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minGas = minGas_;
    }
    function setDefaultFee(uint256 fee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(fee_ <= FEE_DENOM / 10, "Invalid Fee");
        ds.defaultFee = fee_;
    }
    function setUSDC(address USDC_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(USDC_ != address(0), "Zero Address");
        ds.USDC = USDC_;
    }
    function setV2Router(address v2Router_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(v2Router_ != address(0), "Zero Address");
        ds.V2Router = IUniswapV2Router02(v2Router_);
    }
    function setPath(address[] calldata path_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.path = path_;
    }
    function setFeeRecipient(address feeRecipient_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(feeRecipient_ != address(0), "Zero Address");
        ds.feeReceiver = feeRecipient_;
    }
    function withdraw(address token) external onlyOwner {
        TransferHelper.safeTransfer(
            token,
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
    function withdrawETH() external onlyOwner {
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }
}
