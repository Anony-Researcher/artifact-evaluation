// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;


// import "@openzeppelin/contracts/utils/Address.sol";


contract Test2 {

    uint256 constant public MAX_LOCK = 365 days;
    uint256 constant BASE_MULTIPLIER = 1e18;

    event Deposit(uint256 amount);
    event Withdraw(address indexed user, uint256 amountWithdrew, uint256 amountLeft);
    event Lock(address indexed user, uint256 timestamp);
    event Delegate(address indexed from, address indexed to);
    event DelegatedPowerIncreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);
    event DelegatedPowerDecreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);




    address[10] public owners;
    uint j= 100;
    uint i = 10+j;
 
    struct Checkpoint {
        uint256 timestamp;
        address payable amountt;
        uint256 amount;
    }
    string d = "KKKKK";
    mapping(address => uint) public balances;
    address[] public student_result;
    address payable payToThis;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        student_result[0] = address(0);
        emit Deposit(19);
    }

    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    Status public status;
    function withdraw() public {
        Checkpoint memory name;
        name.amount = 100;
        uint bal = balances[msg.sender];
        require(bal > 0);
        
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance()  public returns (uint) {
        emit Withdraw(address(0), 0, 0);
        return address(this).balance;
    }

    function set(Status _status) public {
        status = _status;
    }
}


// things to work on
// 1) Support for structs and enums
// 2) Complicated scenarios such as Macros and User Defined Types
// 3) StateVariable initialisations -> transfer them to constructor -> requires codegen (Not priority/ Semi Automated)
// 4) Derived contracts/ OOP contracts (Not priority)
// payable 
