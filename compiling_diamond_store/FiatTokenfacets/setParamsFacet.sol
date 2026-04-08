pragma solidity ^0.4.17;
import "./TestLib.sol";
contract setParamsFacet is Pausable, StandardToken, BlackList {
    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Ensure transparency by hardcoding limit beyond which fees can never be added
        require(newBasisPoints < 20);
        require(newMaxFee < 50);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10 ** ds.decimals);

        Params(basisPointsRate, maximumFee);
    }
}
