// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Voting {

    struct Election {
        uint id;
        string electionID;
        string electionTitle;
        string[] electionCandidates;
        mapping(uint => uint) electionVotes;
        bool isActive;
    }

    struct Voter {
        address voterAddress;
        bool hasVoted;
        uint votedCandidateId;
    }

    mapping(uint => Election) public elections;
    mapping(address => Voter) public voters;
    uint public electionCount;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    modifier onlyActiveElection(uint _electionId) {
        require(elections[_electionId].isActive, "Election is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createElection(string memory _title, string[] memory _candidates) public onlyOwner {
        electionCount++;
        Election storage newElection = elections[electionCount];
        newElection.id = electionCount;
        newElection.electionTitle = _title;
        newElection.electionCandidates = _candidates;
        newElection.isActive = true;
    }

    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].hasVoted, "Voter is already registered");
        voters[_voter] = Voter(_voter, false, 0);
    }

    function vote(uint _electionId, uint _candidateId) public onlyActiveElection(_electionId) {
        Voter storage sender = voters[msg.sender];
        require(!sender.hasVoted, "You have already voted");
        elections[_electionId].electionVotes[_candidateId]++;
        sender.hasVoted = true;
        sender.votedCandidateId = _candidateId;
    }

    function endElection(uint _electionId) public onlyOwner onlyActiveElection(_electionId) {
        elections[_electionId].isActive = false;
    }

    function getResults(uint _electionId) public view returns (uint[] memory) {
        Election storage election = elections[_electionId];
        uint[] memory results = new uint[](election.electionCandidates.length);
        for (uint i = 0; i < election.electionCandidates.length; i++) {
            results[i] = election.electionVotes[i];
        }
        return results;
    }
}