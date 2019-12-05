pragma solidity ^0.5.12;

library Contract {
    
    struct Building {
        string build_name;
        uint build_number;
        uint total_lots;
        uint size_sqm;
        uint fire_exits;
        address owner;
        address manager;
    }
    
     struct Tenant {
        string name;
        uint tenant_number;
        uint building;
        uint lot;
        uint rent_charge;
        bool owner;
        bool active;
        bool is_authorized;
        address key;
    }
    
    struct Payment {
        uint time;
        uint payable_amount;
        uint start_date;
        uint finish_date;
        uint payment_number;
        bool payed;
        address sender;
        address receiver;
    }
    
     struct Message {
        bytes message;
        address from;
        address too;
    }
    
    struct Rule {
        uint building;
        address setter;
        address[] instructors;
        bytes rule;
        bool active;
    }
    
    struct BuildingInfo {
        mapping (address => bool) authorized;
        Building[] buildings;
    }
    
    struct TenantInfo {
       mapping (address => Tenant) tenants;
       mapping (address => mapping (uint => Building)) localised;
       mapping (address => bool) active_tenants;
       Tenant[] list_of_tenants; 
    }
    
    struct PaymentInfo {
        Payment[] payments_made;
        Payment[] payments_created;
        mapping (address => mapping(uint => Payment)) payment_made;
        mapping (uint => mapping(uint => address)) payed_too;
    }
    
    struct MessageInfo {
        mapping (address => mapping(uint => Message)) messages_sent;
        mapping (address => mapping(uint => Message)) messages_received;
    }
    
    struct RuleInfo {
        mapping(address => mapping(uint => Rule)) rules_set;
        Rule[] rules;
    }

}

contract Buildings {
    
    using Contract for Contract.Building;
    
    Contract.Building building;
    
    modifier isOwnerOrManager(uint _buildNumber) {
        // building storage build = Buildings[_buildNumber];
        require (msg.sender == building.owner || msg.sender == building.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
}
