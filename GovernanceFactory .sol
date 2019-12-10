pragma solidity ^0.5.12;

import"./StateFactoryContract.sol";

contract GovernanceFactory {
    
    using StateFactoryContract for StateFactoryContract.Building;
    using StateFactoryContract for StateFactoryContract.RuleInfo;
    using StateFactoryContract for StateFactoryContract.ProposalInfo;
    
    StateFactoryContract.Building Building;
    StateFactoryContract.RuleInfo rule_info;
    StateFactoryContract.ProposalInfo prop_info;
    
    uint TOTAL_RULES_SET = 0;
    address OWNER;
    
    
    constructor () public {
        OWNER = msg.sender;
    }
    
     modifier isOwnerOrManager(uint _buildNumber) {
        require (msg.sender == Building.owner || msg.sender == Building.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
    function setNewRule(string memory _rule, address[] memory _instructors, uint _buildNumber) public returns (bool rule_set) {
        rule_info.newRule(rule_info.rulings.length, _rule, _instructors, _buildNumber);
        TOTAL_RULES_SET++;
        return rule_set = true;
    }
    
    function setNewProposal(string memory _prop, uint _start_date, uint _finish_date) public returns (bool prop_set) {
        prop_info.newProposal(_prop, _start_date, _finish_date);
        return prop_set;
    }
    
    function voteOnProposal(uint prop_num, address creator) public returns (bool vote_added, uint total_votes) {
        prop_info.proposals_set[creator][prop_num].up_votes++;
        vote_added = true;
        total_votes = prop_info.proposals_set[creator][prop_num].up_votes;
        return (vote_added, total_votes);
    } 
    
    function getRule(uint rule_num) public view returns (bytes memory) {
        return(rule_info.rulings[rule_num]);
    }
    
    function getRuleByManager(address _key, uint _rule) public view returns (bytes memory) {
        return(rule_info.rules[_key][_rule]);
    }
    
    function getRuleInstructors(uint _rule) public view returns (address[] memory) {
        return(rule_info.rule_too_instructors[_rule]);
    }
    
    function getProposal(uint prop_num, address creator) public view returns (bytes memory, uint, uint, uint, uint, address) {
        return(prop_info.proposals_set[creator][prop_num].proposal,
               prop_info.proposals_set[creator][prop_num].up_votes,
               prop_info.proposals_set[creator][prop_num].down_votes,
               prop_info.proposals_set[creator][prop_num].start_date,
               prop_info.proposals_set[creator][prop_num].finish_date,
               prop_info.proposals_set[creator][prop_num].creator);
    }
    
    function getTotalProposals() public view returns (uint) {
        return prop_info.total_proposals.length;
    }
    
    function getTotalAmountOfRules() public view returns (uint) {
        return TOTAL_RULES_SET;
    }
    
    
}
