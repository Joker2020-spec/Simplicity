pragma solidity ^0.5.12;

contract BuildingFactory {
    
    address public owner;
    uint public max_buildings;
    
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
        address key;
    }
    
    mapping (address => Tenant) public tenants;
    
    Tenant[] public list_of_tenants; 
    
    function newTenant(string memory name, uint _lot, uint rent, bool _owner) public {
        Tenant memory tenant = Tenant({name: name, lot: _lot, rent_charge: rent, owner: _owner, key: msg.sender});
        list_of_tenants.push(tenant);
        tenants[msg.sender] = tenant;
    }
    
}
