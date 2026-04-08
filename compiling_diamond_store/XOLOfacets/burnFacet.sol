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
contract burnFacet is ERC20, Ownable {
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
