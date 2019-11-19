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
    
    function newFactory(uint maxlots, uint sizesqm, uint fireexits, address _owner, address _manager) public returns (bool success) {
        require (authorized[msg.sender] == true);
        require (max_buildings > buildings.length);
        Building memory build = Building({max_lots: maxlots, size_sqm: sizesqm, fire_exits: fireexits, owner: _owner, manager: _manager});
        buildings.push(build);
        return success;
    }
    
    function addAuthorizedKey(address newkey) public {
        authorized[newkey] = true;
    }
    
    function removeAuthorizedKey(address badKey) public {
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
        address key;
    }
    
    mapping (address => Tenant) public tenants;
    
    Tenant[] public list_of_tenants; 
    
    function newTenant(string memory name, uint _lot, uint rent, bool _owner) public {
        Tenant memory tenant = Tenant({name: name, lot: _lot, rent_charge: rent, owner: _owner, active: true, key: msg.sender});
        list_of_tenants.push(tenant);
        tenants[msg.sender] = tenant;
    }
    
    function changeDetails(string memory _name, uint _lot, uint _rent, bool _owner, bool _active, address _key) public {
        tenants[msg.sender].name = _name;
        tenants[msg.sender].lot = _lot;
        tenants[msg.sender].rent_charge = _rent;
        tenants[msg.sender].owner = _owner;
        tenants[msg.sender].active = _active;
        tenants[msg.sender].key = _key;
    }

}

contract InteractionFactory is BuildingFactory, TenantFactory {
    
    uint public total_messages;
    
    struct Message {
        bytes message;
        address from;
        address too;
    }
    
    mapping (address => mapping(uint => Message)) messages_sent;
    mapping (address => mapping(uint => Message)) messages_received;
    
    function sendMessage(bytes32 _message, address too) public returns (bool msg_sent) {
        Message memory mess = Message((abi.encode(_message)), msg.sender, too);
        total_messages + 1;
        messages_sent[msg.sender][total_messages] = mess;
        messages_received[msg.sender][total_messages] = mess;
        return msg_sent;
    }
    
    function readMessage(address sender, uint _message) public view returns (bytes memory message) {
        return messages_received[sender][_message].message;
    }
    
}
