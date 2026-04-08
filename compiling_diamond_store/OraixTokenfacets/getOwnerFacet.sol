// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "./TestLib.sol";
contract getOwnerFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    event Transfer(
        address indexed from,
        address indexed to,
        uint value,
        bytes data
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint value,
        bytes data
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint value,
        bytes data
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint value,
        bytes data
    );
    function getOwner() external view returns (address) {
        return owner();
    }
    function decimals() external view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
    function symbol() external view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function name() external view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function totalSupply() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }
    function burn(
        address _to,
        uint256 _amount
    ) public onlyOwner returns (bool) {
        _burn(_to, _amount);
        return true;
    }
    function _burn(address account, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");

        ds._balances[account] = ds._balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        ds._totalSupply = ds._totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _mint(address account, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");

        ds._totalSupply = ds._totalSupply.add(amount);
        ds._balances[account] = ds._balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        ds._balances[recipient] = ds._balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    function transferAndCall(
        address _to,
        uint _value,
        bytes memory _data
    ) public returns (bool success) {
        transfer(_to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        if (isContract(_to)) {
            contractFallback(_to, _value, _data);
        }
        return true;
    }
    function isContract(address _addr) private view returns (bool hasCode) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
    function contractFallback(
        address _to,
        uint _value,
        bytes memory _data
    ) private {
        BEP677Receiver receiver = BEP677Receiver(_to);
        receiver.onTokenTransfer(msg.sender, _value, _data);
    }
}
