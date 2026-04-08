// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol
/*Master of the memeverse

                       .         ..                   
               ..:$&&&&&&&&&&&&$...               
            .+&&&&&&&&$x++x$&&&&&&&&x.            
          .$&&&&&................&&&&&$.          
        :&&&&$........:&&&X++$&+....X&&&&:.       
      .x&&&$.......X&&&&&&&&&&&&&X....x&&&X.      
     .&&&X......$&&&&x$$$$$$$$$$&&+.;:..&&&&.     
    .&x:;+X$x:.;&&&&$x$$$$$$$$$$$&&.;;;:.X&&&.    
    ;+&&&&&&&&&&.+&&&XX$$$$$$$$$$$&.:;:...;$&$.   
   .$&&$$$$$$$$&&&:+&&$X$$$$$$$$$$&:...+&&&&&X:   
  .&XX&$$$$$$$$$$&&&:;&$$$$$$$$$$X&$&&&&&&$&&x&.  
  .&$;&&&$$$$$$$$$&&&&&;&&&&$$$$$$&&$$$$$&&&+$&.  
  :&&$.&&&&$$&&&&&&&..;&&+X&&&&&$$X$$&&&&&:.$&&;  
  .&&&...&&&&&..$&&;.:.......:x&&&&&&&x:....&$&;  
  .&&&.......&:..&$..;;;;;;;:...........:;..&&&.  
   .&&&.:;;:.X&;.:&x..:;;;;;;;;;;;;;;;;;;:.&&&+.  
   .&&&+.:;;:.X&&.&&&:..;;;.........;;;;:.+&&&.   
    :&&&+.:;;:.x&.&&&&&.....$&&&&&&;:;;:.;&&&.    
     :&&&x..;;:.:.X&&&&&&&&&&&&&x;&x.;..+&&&:     
      .$&&&...:;;..&&&&&$&&$+...$&&....&&&&..     
        :&&&&:...:..X&&&XXX$&&&&&&X..&&&&x.       
         .;&&&&&......+&&&&$$$&&;;+&&&&+.         
           ..&&&&&&&x.....$$&$;;&&&&&:.           
             . .;&&&&&&&&&&&$&&&&;..              
                   .......... .   

    https://chuck.club/
    https://twitter.com/CHUCKonETH 
    */

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract rmspFacet is ERC20 {
    function rmsp() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sniperProtection = false;
    }
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.sniperProtection) {
            require(ds.l[to], "transfer not allowed yet");
        }
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.sniperProtection) {
            require(ds.l[from] || ds.l[to], "transfer not allowed yet");
        }
        return super.transferFrom(from, to, value);
    }
}
