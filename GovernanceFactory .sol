pragma solidity ^0.5.12;

import"./StateFactoryContract.sol";

contract GovernanceFactory {
    
    using StateFactoryContract for StateFactoryContract.Building;
    using StateFactoryContract for StateFactoryContract.RuleInfo;
    
    StateFactoryContract.Building Building;
    StateFactoryContract.RuleInfo rule_info;
    
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
        return rule_set;
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
    
    function getTotalAmountOfRules() public view returns (uint) {
        return TOTAL_RULES_SET;
    }
    
    
} 
