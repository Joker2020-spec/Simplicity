pragma solidity ^0.5.12;

import"./Untitled.sol";

contract GovernanceFactory {
    
    using StateFactoryContract for StateFactoryContract.Building;
    // using StateFactoryContract for StateFactoryContract.Rule;
    using StateFactoryContract for StateFactoryContract.RuleInfo;
    
    StateFactoryContract.Building Building;
    StateFactoryContract.RuleInfo rule_info;
    //  StateFactoryContract.Rule rule;
    
    uint TOTAL_RULES_SET = 0;
    address OWNER;
    
    uint[] total_rules;
    
    constructor () public {
        OWNER = msg.sender;
    }
    
     modifier isOwnerOrManager(uint _buildNumber) {
        require (msg.sender == Building.owner || msg.sender == Building.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
    function setNewRule(string memory _rule, address[] memory _instructors, uint _buildNumber) public isOwnerOrManager(_buildNumber) returns (bool rule_set) {
        rule_info.newRule(_rule, _instructors, _buildNumber);
        TOTAL_RULES_SET++;
        total_rules.push(TOTAL_RULES_SET);
        return rule_set;
    }
    
} 
