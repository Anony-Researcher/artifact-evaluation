/*
https://t.me/fullmetalshiba
                                                                        
                                                                        
FFFFFFFFFFFFFFFFFFFFFFMMMMMMMM               MMMMMMMM   SSSSSSSSSSSSSSS 
F::::::::::::::::::::FM:::::::M             M:::::::M SS:::::::::::::::S
F::::::::::::::::::::FM::::::::M           M::::::::MS:::::SSSSSS::::::S
FF::::::FFFFFFFFF::::FM:::::::::M         M:::::::::MS:::::S     SSSSSSS
  F:::::F       FFFFFFM::::::::::M       M::::::::::MS:::::S            
  F:::::F             M:::::::::::M     M:::::::::::MS:::::S            
  F::::::FFFFFFFFFF   M:::::::M::::M   M::::M:::::::M::::SSSS         
  :::::::𝐅𝐔𝐋𝐋::::::  ::::::::::: 𝐌𝐄𝐓𝐀𝐋 ::::::::::::  𝐒𝐇𝐈𝐁𝐀:::::
  F:::::::::::::::F   M::::::M  M::::M::::M  M::::::M    SSS::::::::SS  
  F::::::FFFFFFFFFF   M::::::M   M:::::::M   M::::::M       SSSSSS::::S 
  F:::::F             M::::::M    M:::::M    M::::::M            S:::::S
  F:::::F             M::::::M     MMMMM     M::::::M            S:::::S
FF:::::::FF           M::::::M               M::::::MSSSSSSS     S:::::S
F::::::::FF           M::::::M               M::::::MS::::::SSSSSS:::::S
F::::::::FF           M::::::M               M::::::MS:::::::::::::::SS 
FFFFFFFFFFF           MMMMMMMM               MMMMMMMM SSSSSSSSSSSSSSS   
                                                                        
                                                          
                                                                        
*/
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet is ERC20 {
    function decimals() public view virtual override returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
