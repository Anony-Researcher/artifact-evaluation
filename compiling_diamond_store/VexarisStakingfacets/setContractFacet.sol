// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract setContractFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    event LogSetContract(CONTRACTS contractType, address indexed _contract);
    event LogWarmupPeriod(uint period);
    function setContract(
        TestLib.CONTRACTS _contract,
        address _address
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_contract == TestLib.CONTRACTS.DISTRIBUTOR) {
            // 0
            ds.distributor = IDistributor(_address);
        } else if (_contract == TestLib.CONTRACTS.WARMUP) {
            // 1
            require(
                address(ds.warmupContract) == address(0),
                "Warmup cannot be set more than once"
            );
            ds.warmupContract = IWarmup(_address);
        }
        emit LogSetContract(_contract, _address);
    }
    function setWarmup(uint _warmupPeriod) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.warmupPeriod = _warmupPeriod;
        emit LogWarmupPeriod(_warmupPeriod);
    }
}
