// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getAirdropPerAccountAmountFacet {
    function getAirdropPerAccountAmount() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.airdropPerAccountAmount;
    }
}
