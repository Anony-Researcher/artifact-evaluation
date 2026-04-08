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
contract burnFromFacet is ERC20, Ownable {
    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}
