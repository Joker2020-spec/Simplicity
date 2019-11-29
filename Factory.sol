pragma solidity ^0.5.12;

contract BuildingFactory {
    
    address public owner;
    uint public max_buildings = 50;
    
    struct Building {
        uint max_lots;
        uint size_sqm;
        uint fire_exits;
        address owner;
        address manager;
    }
    
    mapping (address => bool) private authorized;
    
    Building[] public buildings;
    
    constructor () internal {
        owner = msg.sender;
    }
    
    modifier isOwnerOrManager(uint _buildNumber) {
        Building storage build = buildings[_buildNumber];
        require (msg.sender == build.owner || msg.sender == build.manager);
        _;
    }
    
    modifier isAuthorized() {
        require (authorized[msg.sender] = true);
        _;
    }
    
    function newFactory(uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) public returns (bool success) {
        require (authorized[msg.sender] == true);
        require (max_buildings > buildings.length);
        Building memory build = Building({max_lots: maxlots, size_sqm: sizesqm, fire_exits: fire_exits, owner: _owner, manager: _manager});
        buildings.push(build);
        return success;
    }
    
    function addAuthorizedKey(address newkey) internal {
        authorized[newkey] = true;
    }
    
    function removeAuthorizedKey(address badKey) internal {
        authorized[badKey] = false;
    }

}

contract TenantFactory is BuildingFactory {
    
    struct Tenant {
        string name;
        uint lot;
        uint rent_charge;
        bool owner;
        bool active;
        bool is_authorized;
        address key;
    }
    
    mapping (address => Tenant) public tenants;
    
    Tenant[] public list_of_tenants; 
    
    modifier isActive(uint _tenantNumber) {
        Tenant storage tent = list_of_tenants[_tenantNumber];
        require (tent.key == msg.sender);
        require (tent.active = true);
        _;
    }
    
    function newTenant(string memory name, uint _lot, uint rent, bool _owner) public {
        Tenant memory tenant = Tenant({name: name, lot: _lot, rent_charge: rent, owner: _owner, active: true, is_authorized: false, key: msg.sender});
        list_of_tenants.push(tenant);
        tenants[msg.sender] = tenant;
    }
    
    function changeDetails(uint _tenantNumber, string memory _name, uint _lot, uint _rent, bool _owner, bool _active, address _key) public isActive(_tenantNumber) {
        Tenant storage tent = list_of_tenants[_tenantNumber];
        tent.name = _name;
        tent.lot = _lot;
        tent.rent_charge = _rent;
        tent.owner = _owner;
        tent.active = _active;
        tent.key = _key;
    }
    
    function authorizeTenant(address _tenant, uint _tenantNumber) public isAuthorized {
        Tenant storage tent = list_of_tenants[_tenantNumber];
        require (tent.key == _tenant);
        tent.is_authorized = true;
        addAuthorizedKey(_tenant);
    }
    
    function deAuthorizeTenant(address _tenant, uint _tenantNumber) public isAuthorized {
        Tenant storage tent = list_of_tenants[_tenantNumber];
        require (tent.key == _tenant);
        tent.is_authorized = false;
        removeAuthorizedKey(_tenant);
    }

}

contract InteractionFactory is BuildingFactory, TenantFactory {
    
    uint public total_messages;
    uint public total_rules;
    
    struct Message {
        bytes message;
        address from;
        address too;
    }
    
    struct Rule {
        address setter;
        address[] instructors;
        bytes rule;
        bool active;
    }
    
    mapping (address => mapping(uint => Message)) messages_sent;
    mapping (address => mapping(uint => Message)) messages_received;
    
    Rule[] public rules;
    
    function sendMessage(string memory _message, address too) public returns (bool msg_sent_success) {
        Message memory mess = Message((abi.encode(_message)), msg.sender, too);
        total_messages++;
        messages_sent[msg.sender][total_messages] = mess;
        messages_received[too][total_messages] = mess;
        return msg_sent_success;
    }
    
    function readMessage(uint _message) public view returns (bytes memory message) {
        return messages_received[msg.sender][_message].message;
    }
    
    function setNewRuling(string memory _rule, address[] memory _instructors, uint _buildNumber) public isOwnerOrManager(_buildNumber) returns (bool success) {
        address[] memory rule_instructors = _instructors;
        Rule memory newRule = Rule(msg.sender, rule_instructors, (abi.encode(_rule)), true);
        rules.push(newRule);
        total_rules = rules.length;
        return success;
    }
}
