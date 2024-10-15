// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vote {

//first entity
struct Voter {
    string name;
    uint age;
    uint voterId;
    Gender gender;
    uint voteCandidateId; //candidate id to whom the voter has voted
    address voterAddress; //EOA of the voter
}

//second entity
struct Candidate {
    string name;
    string party;
    uint age;
    Gender gender;
    uint candidateId;
    address candidateAddress;//candidate EOA
    uint votes; //number of votes
}

//third entity
address public electionCommission;
address public winner;
uint nextVoterId = 1;
uint nextCandidateId = 1;

//voting period
uint startTime;
uint endTime;
bool stopVoting;
mapping(uint => Voter) voterDetails;
mapping(uint => Candidate) candidateDetails;

//IERC20 public gldToken;

enum VotingStatus {NotStarted, InProgress, Ended}
enum Gender {NotSpecified, Male, Female, Other}

//constructor(address _gldToken) {
  //  gldToken = IERC20(_gldToken);
    //electionCommission=msg.sender;//msg.sender is a global variable
//}

modifier isVotingOver() {
    require(block.timestamp<=endTime && stopVoting==false,"Voting time is over");
  _;
}



modifier onlyCommissioner() {
    require(msg.sender==electionCommission,"Not authuorized");
    _;
}


 modifier isValidAge(uint _age){
    require(_age>=18,"not eligible for voting");  
    _;
}





function registerCandidate(string calldata name, string calldata party, uint age, Gender gender) external isValidAge(age){
    require(isCandidateNotRegistered(msg.sender),"Already Regitered");
    require(nextCandidateId<3,"Not Allowed");
    require(msg.sender!=electionCommission,"EC not allowed to vote");
     candidateDetails[nextVoterId]=Candidate({  //candidateDetails naam ke mapping me nextVoterId ke samne candidate ki sari info store karayi ja rahi hain
        name:name,
        party:party,
        gender:gender,
        age:age,
        candidateId:nextCandidateId,
        candidateAddress:msg.sender,
        votes:0
     });
     nextCandidateId++;
}


function isCandidateNotRegistered(address person)private view returns(bool){
for(uint i=1;i<nextCandidateId;i++)
{
    if(candidateDetails[i].candidateAddress==person)               //checks if mapping named as candidateDetails at i'th position has candidateddress equal to the person registering or not
    return false;
}
return true;
}
//false means candidate is registered and true means cadidate is not registered




function getCandidateList()public view returns (Candidate[]memory)
{
    Candidate[] memory candidateList= new Candidate[](nextCandidateId-1);
    //candidate type ka candidateList naam se ek array bnaya which stores the length of candidate through nextCandidateId
    for(uint i=1;i<candidateList.length;i++)
    {
        candidateList[i]=candidateDetails[i+1];
//ek ek karke candidateList me candidateDetails daal do
    }
    return candidateList;
}

function registerVoter(string calldata name,  uint age, Gender gender) external isValidAge(age){
    require(isVoterNotRegistered(msg.sender),"Already Registered");
    voterDetails[nextVoterId]=Voter({
        name:name,
        age:age,
        voterId:nextVoterId,
        gender:gender,
        voteCandidateId:0,
        voterAddress:msg.sender
    });
    nextVoterId++;
}

function isVoterNotRegistered(address person) private view returns(bool)
{
    for(uint i=1;i<nextVoterId;i++)
    {
        if(voterDetails[i].voterAddress==person)
        return false;
    }
    return true;
}






function getVoterList() public view returns(Voter[] memory)
{
    Voter[]memory voterList=new Voter[](nextVoterId-1);
    for(uint i=1;i<nextVoterId;i++)
    {
        voterList[i]=voterDetails[i+1];
    }
      return voterList;
}


function castVote(uint voterId, uint candidateId) external isVotingOver //modifier to check if votig is still going on 
{
//require(gld.balanceOf(msg.sender)>0,"Insuffiient balance");
require(block.timestamp>=startTime,"voting over");
require(voterDetails[voterId].voterAddress==msg.sender,"Not authenticated"); //voterId is a unique identifier assigned to each voter 
require(voterDetails[voterId].voteCandidateId==0,"already Voted");

voterDetails[voterId].voteCandidateId=candidateId;   // voterDetails naam ke map me voterId suppose3 ne vote kiya candidateId 5 ko to map me store ho jayega ki kis voterId ne kis candidateId o vote kiya
candidateDetails[candidateId].votes++;  //jo bhi candidateId ko vote pada hoga uske votes ko badha denge
}



function setVotingPeriod(uint _startTimeDuration, uint _endTimeDuration) external onlyCommissioner() {
    require(_endTimeDuration > 3600, "_endTimeDuration must be greater than 1 hour");
    startTime = 1720799550 + _startTimeDuration;
    endTime = startTime + _endTimeDuration;
}



function getVotingStatus() public view returns (VotingStatus) {
    if (startTime == 0) {
        return VotingStatus.NotStarted; //enums are being used here
    } else if (endTime > block.timestamp && stopVoting == false) {
        return VotingStatus.InProgress;   // InProgress is an enum
    } else {
        return VotingStatus.Ended;
    }
}


function result() external onlyCommissioner() {
uint max=0;
for(uint i=1;i<nextCandidateId;i++)
{
   if( candidateDetails[i].votes>max)
   {
    max=candidateDetails[i].votes;
    winner=candidateDetails[i].candidateAddress;
   }
}
}
}