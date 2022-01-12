pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  bool openForWithdrawal = false;
  ExampleExternalContract public exampleExternalContract;
  mapping(address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 60 seconds;


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

event Stake(address indexed sender, uint balance);
event Log(string msg);
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
function  stake() public payable {
  address _addr = msg.sender;
  balances[_addr] = address(this).balance;
  emit Stake(_addr, balances[_addr]);
}

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {

      if (address(this).balance >= threshold && timeLeft() > 0){
        exampleExternalContract.complete{value: address(this).balance}();
      }
      // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      if (address(this).balance < threshold) {
        openForWithdrawal = true;
      }
  }



  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw(address payable _addr) public {
    require(openForWithdrawal, "Withdrawal not open");
    (bool success, ) = _addr.call{value: balances[_addr]}("");
    require(success, "Failed to send ETH");
    delete balances[_addr];

  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256){
    if (block.timestamp >= deadline){
      return 0;
    }
    else
    {
      return deadline - block.timestamp;
    }
  }

  event Received(address, uint);

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    emit Received(msg.sender, msg.value);
    stake();
  }

}
