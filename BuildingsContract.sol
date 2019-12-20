pragma solidity ^0.5.12;

import"./StateFactoryContract.sol";

contract BuildingsContract {
    
    address public owner;
    uint public current_buildings = 0;
    uint public max_buildings = 50;
    
    using StateFactoryContract for StateFactoryContract.Building;
    using StateFactoryContract for StateFactoryContract.BuildingInfo;
    
    StateFactoryContract infomation;
    StateFactoryContract.Building Building;
    StateFactoryContract.BuildingInfo buildingInfo;
    
    uint[] buildings;
    
     constructor () internal {
        owner = msg.sender;
        buildingInfo.authorized[owner] = true;
    }
    
    modifier isOwnerOrManager(uint _buildNumber) {
        require (msg.sender == Building.owner || msg.sender == Building.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
    modifier isAuthorized() {
        require (buildingInfo.authorized[msg.sender] = true, 
                    "Check to see if the key calling the function is authorized to do so!");
        _;
    }
    
    
    function newBuilding(string memory _name, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) public returns (bool success) {
        require (max_buildings > buildings.length,
                        "The amount of buildings using the contract is not above the MAX LIMIT of 50");
        buildingInfo.NewFactory(_name, buildings.length, maxlots, sizesqm, fire_exits, _owner, _manager);
        current_buildings++;
        buildings.push(current_buildings);
        return success;
    }
    
    function getBuilding(address _owner) public view returns (string memory, uint, uint, uint, uint, address, address) {
        return(buildingInfo.owners[_owner].build_name,
               buildingInfo.owners[_owner].build_number,
               buildingInfo.owners[_owner].total_lots,
               buildingInfo.owners[_owner].size_sqm,
               buildingInfo.owners[_owner].fire_exits,
               buildingInfo.owners[_owner].owner,
               buildingInfo.owners[_owner].manager);
    }
    
    function addAuthorizedKey(address newkey) internal {
        buildingInfo.authorized[newkey] = true;
    }
    
    function removeAuthorizedKey(address badKey) internal {
        buildingInfo.authorized[badKey] = false;
    }
    
}
