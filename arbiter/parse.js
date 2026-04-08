const fs = require('fs');
function parse(code){
    abstract contract Context {
    
        function _msgData() internal view virtual returns (bytes calldata);
    }
    
    interface IERC20 {
        function transfer(address r, uint256 amt) external returns (bool);
    }
    
    library SafeMath {
    
    }
    
    contract Ownable {
        
    }
    
    contract Example is Context, IERC20, Ownable {
        using SafeMath for uint256;
        uint256 private constant toAdd = 10;
        uint256 private temp;
    
        function _msgData() internal view virtual override returns (bytes calldata) {
            return msg.data;
        }
    
        function transfer(address r, uint256 amt) public override returns (bool) {
            _transfer(address(0), r, amt);
            return true;
        }
    
        function approve(address s, uint256 amt) public returns (bool) {
            _approve(address(0), s, amt);
            return true;
        }
    
        function _approve(address owner, address spender, uint256 amt) private {
            temp = temp + toAdd;
        }
    
        function _transfer(address from, address to, uint256 amt) private {
            temp = temp + 1;
        }
    }
 let ast = {
   body:[
     {type:'contract'}
    ]
 }
 return Promise.resolve(ast);
}
module.exports = parse;