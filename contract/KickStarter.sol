// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.17;

contract Campaign{

    // for creating the requests for manager ordering 
     struct Request{
         string description;
         uint value;
         address recipient;
         bool complete;
         uint approvalcount;
         mapping(address => bool) approvals;
     }
    Request[] public requests;
    address public manager;
    uint public minimumcontribution;
    mapping(address=>bool) public approvers;
    uint public approversCount;

// taking some minimum amount to contribute and address of manager
 function campaign(uint minimum,address creator) public restricted{
    manager = creator;
    minimumcontribution = minimum;
}
// Taking money from the contributers and making them approvers
 function contribute() public payable{
     require(minimumcontribution<msg.value);
     approvers[msg.sender]=true;
     approversCount++;
 }

// a modifier to restrict the access to only manager
 modifier restricted{
     require(msg.sender==manager);
     _;
 }
 // This is created for manager to create the request and allow approvers to accept 
 function createrequest(string memory description , uint value ,address recipient) public restricted {
     Request memory newRequest = Request({
         description : description,
         value : value,
         recipient : recipient,
         complete : false,
         approvalcount:0
     });
     requests.push(newRequest);
   }

// here we approve the requests of the manager's by accessing them using index provided
 function approvalrequest(uint index) public {
    require(approvers[msg.sender]);
    Request storage request = requests[index];
    require(!request.approvals[msg.sender]);
    request.approvals[msg.sender]=true;
    request.approvalcount ++;
 }

// after getting the approvals we finally verify the request and pass amount to manager
 function finalizerequest(uint index) public restricted{
  Request storage request =requests[index];
  require(request.approvalcount>(approversCount/2));
  require(!request.complete);
  request.recipient.transfer(request.value);
  request.complete = true;
 }

}