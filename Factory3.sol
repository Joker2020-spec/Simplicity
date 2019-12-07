pragma solidity ^0.5.12;


library StateFactoryContract {
    
    
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
        uint rule_number;
        address setter;
        address[] instructors;
        bytes rule;
        bool active;
    }
   
   
    struct BuildingInfo {
        mapping (address => Building) owners;
        mapping (address => bool) authorized;
    }
    
   
    struct TenantInfo {
       mapping (address => Tenant) tenants;
       mapping (address => mapping (uint => uint)) localised;
       mapping (address => bool) active_tenants;
    }
    
    struct PaymentInfo {
        mapping (address => mapping (uint => Payment)) payments_created;
        mapping (address => mapping(uint => address)) payments_made;
        uint[] total_payments;
    }
    
    struct MessageInfo {
        mapping (address => mapping(uint => Message)) messages_sent;
        mapping (address => mapping(uint => Message)) messages_received;
    }
    
    struct RuleInfo {
        mapping(address => mapping(uint => Rule)) rules_set;
        mapping(address => mapping(uint => bytes[])) rules;
        bytes[] rulings;
    }
    
    function NewFactory(BuildingInfo storage build, string memory _name, uint _buildNum, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) internal {
        require (build.authorized[msg.sender] == true,
                    "The creator of the Factory is an authorzied key");
        _buildNum = 0;            
        build.owners[msg.sender] = Building(
            _name,
            _buildNum,
            maxlots,
            sizesqm,
            fire_exits,
            _owner,
            _manager);
    }
    
    function newTenant(TenantInfo storage tenant, string memory _name, uint _tenantNum, uint building_num,  uint _lot, uint _rent, bool _owner) internal {
        tenant.tenants[msg.sender] = Tenant(
            _name,
            _tenantNum,
            building_num,
            _lot,
            _rent,
            _owner,
            true,
            false,
            msg.sender);
        tenant.active_tenants[msg.sender] = true;
    }
    
    function changeTenantDetails(TenantInfo storage tenant, string memory _name, uint _tenantNumber, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) internal {
        tenant.tenants[_key] = Tenant(
            _name,
            _tenantNumber,
            _building,
            _lot,
            _rent,
            _owner,
            _active,
            false,
            _key);
    }
    
    function createPayment(PaymentInfo storage payment, uint _amount, uint _timeLength) internal {
        payment.total_payments.length++;
        uint payment_num = payment.total_payments.length;
        payment.payments_created[msg.sender][payment_num] = Payment(
            _timeLength, 
            _amount, 
            0, 
            0, 
            payment.total_payments.length, 
            false, 
            address(0),
            msg.sender);
    }
    
    function changePaymentDetails(PaymentInfo storage payment, uint new_time, uint new_amount, uint _payNum) internal {
        payment.payments_created[msg.sender][_payNum].time = new_time;
        payment.payments_created[msg.sender][_payNum].payable_amount = new_amount;
    }
    
    function newRule(RuleInfo storage rule, uint _rule_num, string memory _rule, address[] memory _instructors, uint _buildNumber) internal {
        // _rule_num = rule.rulings.length;
        bytes memory new_rule = abi.encode(_rule);
        _rule_num = rule.rulings.push(new_rule);
        rule.rules_set[msg.sender][_buildNumber] = Rule(_buildNumber, rule.rulings.length, msg.sender, _instructors, new_rule, true);
        rule.rules[msg.sender][_rule_num].push(new_rule);
    }
    
    
}

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
    
    function addAuthorizedKey(address newkey) internal {
        buildingInfo.authorized[newkey] = true;
    }
    
    function removeAuthorizedKey(address badKey) internal {
        buildingInfo.authorized[badKey] = false;
    }
    
}

contract TenantContract is BuildingsContract {
    
    
    uint public TOTAL_AMOUNT_OF_TENANTS = 0;
    
    
    using StateFactoryContract for StateFactoryContract.TenantInfo;
    
    
    StateFactoryContract.TenantInfo tenantInfo;
    
    
    uint[] list_of_tenants;
    
    
     modifier isActive(address _key) {
        require (tenantInfo.active_tenants[_key] == true,
                    "Check to ensure that the key interacting with the function is active with contract");
        _;
    }
    
    function addNewTenant(string memory _name, uint building_num,  uint _lot, uint _rent, bool _owner) public returns (bool success) {
        TOTAL_AMOUNT_OF_TENANTS++;
        list_of_tenants.push(TOTAL_AMOUNT_OF_TENANTS);
        tenantInfo.localised[msg.sender][list_of_tenants.length] = building_num;
        tenantInfo.newTenant(_name, list_of_tenants.length, building_num, _lot, _rent, _owner);
        return success;
    }
    
    function changeDetailsOfTenant(string memory _name, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) public returns (bool success) {
        tenantInfo.changeTenantDetails(_name, list_of_tenants.length, _building, _lot, _rent, _owner, _active, _key);
        return success;
    }
    
    function getTenantBasicInfo(address _key) public view returns (string memory, uint, uint, uint, bool, address) {
        return(tenantInfo.tenants[_key].name,
               tenantInfo.tenants[_key].tenant_number,
               tenantInfo.tenants[_key].building,
               tenantInfo.tenants[_key].lot,
               tenantInfo.tenants[_key].active,
               tenantInfo.tenants[_key].key);
    }
    
    function getTenantPrivateInfo(address _key) public view returns (uint, bool, bool) {
        return(tenantInfo.tenants[_key].rent_charge,
               tenantInfo.tenants[_key].owner,
               tenantInfo.tenants[_key].is_authorized);
    }
    
    function authorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, "Check to see if the key being authorized matches the key linked to the tenant");
        tenantInfo.tenants[_key].is_authorized = true;
        addAuthorizedKey(_key);
        return true;
    }
    
    function deAuthorizeTenant(address _key) public returns (bool) {
        require(tenantInfo.tenants[_key].key == _key, "Check to see if the key being de-authorized matches the key linked to the tenant");
        require(tenantInfo.tenants[_key].is_authorized == true, "Check to see if the key is currently authorized");
        tenantInfo.tenants[_key].is_authorized = false;
        removeAuthorizedKey(_key);
        return true;
    }
    
    function totalTenants() public view returns (uint) {
        return(list_of_tenants.length);
    }
    
}

contract PaymentContract is TenantContract {
    
    
    using StateFactoryContract for StateFactoryContract.PaymentInfo;
    
    
    StateFactoryContract.PaymentInfo payment_info;
    
    uint8 NON_PAYMENT = 0;
    uint public TOTAL_PAYMENTS_MADE = 0;
    uint8 public TOTAL_PAYMENTS_CREATED = 0;
    uint24 MAX_PAYMENT_TERMS = 30 days;
    uint24 MIN_PAYMENT_TERMS = 1 days;
    
    
    uint[] payments_created;
    uint[] payments_made;
    
    mapping (address => mapping(uint => mapping(uint => mapping(address => bool)))) payments_finalised;
    
    
    function generatePayment(uint _amount, uint _timeLength) public returns (bool success, uint payment_number) {
        checkTimePeriod(_timeLength);
        payment_info.createPayment(_amount, _timeLength);
        TOTAL_PAYMENTS_CREATED++;
        payments_created.push(TOTAL_PAYMENTS_CREATED);
        return (success, payments_created.length);
    }
    
    function getPaymentDetails(address _key, uint _payment_number) public view returns (uint, uint, uint, uint, uint, bool) {
        return(payment_info.payments_created[_key][_payment_number].time,
               payment_info.payments_created[_key][_payment_number].payable_amount,
               payment_info.payments_created[_key][_payment_number].start_date,
               payment_info.payments_created[_key][_payment_number].finish_date,
               payment_info.payments_created[_key][_payment_number].payment_number,
               payment_info.payments_created[_key][_payment_number].payed);
    }
    
    function changeDetailsOfPayment(uint new_time, uint new_amount, uint _payment) public returns (bool) {
        for (uint i = 0; i < payments_created.length; i++) {
            if (payments_created[i] == _payment) {
                payment_info.changePaymentDetails(new_time, new_amount, _payment);
                return true;
            }  
        }
        
    }
    
    function finalisePayment(uint _amount, uint pay_num, uint _finish_date, address _too) public returns (bool success) {
        checkAddress(_too);
        checkPaymentValid(_too, pay_num);
        checkPayableAmount(_amount, pay_num, _too);
         for (uint i = 0; i < payments_created.length; i++) {
             if (payments_created[i] == pay_num) {
                 payment_info.payments_created[_too][pay_num].payable_amount = _amount;
                 payment_info.payments_created[_too][pay_num].start_date = now;
                 payment_info.payments_created[_too][pay_num].finish_date = _finish_date;
                 payment_info.payments_created[_too][pay_num].payment_number = payments_created.length;
                 payment_info.payments_created[_too][pay_num].payed = true;
                 payment_info.payments_created[_too][pay_num].sender = msg.sender;
                 payment_info.payments_created[_too][pay_num].receiver = _too;
                 payments_finalised[msg.sender][pay_num][_amount][_too] = true;
                 payment_info.payments_made[msg.sender][pay_num] = _too;
                 TOTAL_PAYMENTS_MADE++;
             }
         }
         payments_made.push(pay_num);
         return success;
    }
    
    function getFinalisedPayment(address _too, uint pay_num) public view returns (uint, uint, uint, bool, address, address) {
        return(payment_info.payments_created[_too][pay_num].payable_amount,
               payment_info.payments_created[_too][pay_num].start_date,
               payment_info.payments_created[_too][pay_num].finish_date,
               payment_info.payments_created[_too][pay_num].payed,
               payment_info.payments_created[_too][pay_num].sender,
               payment_info.payments_created[_too][pay_num].receiver);
    }
    
    function isPaymentFinalised(address _from, address _too, uint _amount, uint _payNum) public view returns (bool) {
        return(payments_finalised[_from][_payNum][_amount][_too]);
    }
    
    function checkAddress(address _too) internal view {
        if (msg.sender == _too) {
            revert("The sender and receiver have the same address");
        }
    }
    
    function checkCreatorValid(uint pay_num) internal view {
        require(payment_info.payments_created[msg.sender][pay_num].receiver == msg.sender,
                    "The creator of the payment is the address that will receive the payment");
    }
    
    function checkTimePeriod(uint _timeLength) internal view {
        require (MIN_PAYMENT_TERMS <= _timeLength, 
                    "The time allocated to the payment is greater or equal to the minimum payment terms of 1 day!");
        require (MAX_PAYMENT_TERMS >= _timeLength, 
                    "The time allocated to the payment is less than or equal to the maximum payment terms of 30 days!");
    }
    
    function checkPaymentValid(address _too, uint pay_num) internal view {
        require(payment_info.payments_created[_too][pay_num].payed == false,
                    "The payment has not executed yet");
    }
    
    function checkPayableAmount(uint _amount, uint pay_num, address _too) internal view {
        require (payment_info.payments_created[_too][pay_num].payable_amount == _amount, 
                    "The amount due against the payment is equal to the value being sent");
    }

}
