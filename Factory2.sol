pragma solidity ^0.5.12;

contract BuildingFactory {
    
    address public owner;
    uint public current_buildings = 0;
    uint public max_buildings = 50;
    
    struct Building {
        string build_name;
        uint build_number;
        uint total_lots;
        uint size_sqm;
        uint fire_exits;
        address owner;
        address manager;
    }
    
    mapping (address => bool) private authorized;
    
    Building[] public buildings;
    
    constructor () internal {
        owner = msg.sender;
        authorized[owner] = true;
    }
    
    modifier isOwnerOrManager(uint _buildNumber) {
        Building storage build = buildings[_buildNumber];
        require (msg.sender == build.owner || msg.sender == build.manager,
                    "Caller of the function is the owner or manager of the building");
        _;
    }
    
    modifier isAuthorized() {
        require (authorized[msg.sender] = true);
        _;
    }
    
    function newFactory(string memory build_name, uint maxlots, uint sizesqm, uint fire_exits, address _owner, address _manager) public returns (bool success) {
        require (authorized[msg.sender] == true,
                    "The creator of the Factory is an authorzied key");
        require (max_buildings > buildings.length,
                        "The amount of buildings using the contract is not above the MAX LIMIT of 50");
        Building memory build = Building({build_name: build_name, build_number: buildings.length, total_lots: maxlots, size_sqm: sizesqm, fire_exits: fire_exits, owner: _owner, manager: _manager});
        current_buildings++;
        buildings.push(build) - current_buildings;
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
        uint tenant_number;
        uint building;
        uint lot;
        uint rent_charge;
        bool owner;
        bool active;
        bool is_authorized;
        address key;
    }
    
    mapping (address => Tenant) tenants;
    mapping (address => mapping (uint => Building)) localised;
    mapping (address => bool) public active_tenants;
    
    Tenant[] public list_of_tenants; 
    
    modifier isActive() {
        require (active_tenants[msg.sender] == true);
        _;
    }
    
    function newTenant(string memory name, uint building_num,  uint _lot, uint rent, bool _owner) public {
        Tenant memory tenant = Tenant({name: name, tenant_number: list_of_tenants.length, building: building_num, lot: _lot, rent_charge: rent, owner: _owner, active: true, is_authorized: false, key: msg.sender});
        active_tenants[msg.sender] = true;
        list_of_tenants.push(tenant);
        tenants[msg.sender] = tenant;
        Building storage build = buildings[building_num];
        localised[msg.sender][_lot] = build;
    }
    
    function changeDetails(uint _tenantNumber, string memory _name, uint _building, uint _lot, uint _rent, bool _owner, bool _active, address _key) public isActive() {
        Tenant storage tent = list_of_tenants[_tenantNumber];
        tent.name = _name;
        tent.building = _building;
        tent.lot = _lot;
        tent.rent_charge = _rent;
        tent.owner = _owner;
        tent.active = _active;
        tent.key = _key;
    }
    
    function getTenantInfo(uint _tenantNum) public view returns (string memory, uint, uint, uint, bool, bool, address) {
        return(list_of_tenants[_tenantNum].name,
               list_of_tenants[_tenantNum].building,
               list_of_tenants[_tenantNum].lot,
               list_of_tenants[_tenantNum].rent_charge,
               list_of_tenants[_tenantNum].owner,
               list_of_tenants[_tenantNum].active,
               list_of_tenants[_tenantNum].key);
            
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
        tent.active = false;
        tent.is_authorized = false;
        removeAuthorizedKey(_tenant);
    }

}

contract Payments is TenantFactory {
    
    uint8 NON_PAYMENT = 0;
    uint public TOTAL_PAYMENTS_MADE = 0;
    uint8 public TOTAL_PAYMENTS_CREATED = 0;
    uint24 MAX_PAYMENT_TERMS = 30 days;
    uint24 MIN_PAYMENT_TERMS = 1 days;
    
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
    
    Payment[] payments_made;
    Payment[] payments_created;
    
    mapping (address => mapping(uint => Payment)) payment_made;
    mapping (uint => mapping(uint => address)) payed_too;
    
    function createPayment(uint _amount, uint _time) public  isAuthorized() returns (bool success) {
        TOTAL_PAYMENTS_CREATED++;
        Payment memory payment = Payment({
            time: _time, 
            payable_amount: _amount, 
            start_date: 0, 
            finish_date: 0, 
            payment_number: TOTAL_PAYMENTS_CREATED, 
            payed: false, 
            sender: address(0),
            receiver: msg.sender
        });
        payments_created.push(payment);
        // checkCreatorValid(payment.payment_number);
        return success;
    }
    
    function getPaymentTerms(uint _payment) public view returns (uint, uint, uint, uint, uint, bool) {
        return(payments_created[_payment].time,
               payments_created[_payment].payable_amount,
               payments_created[_payment].start_date,
               payments_created[_payment].finish_date,
               payments_created[_payment].payment_number,
               payments_created[_payment].payed);
    }
    
    function makePayment(uint _amount, uint pay_num, uint _finish_date, address _too) public isActive() returns (bool success) {
        checkAddress(_too);
        checkTimePeriod(pay_num);
        checkPayableAmount(_amount, pay_num);
        checkPaymentValid(pay_num);
        Payment storage payment = payments_created[pay_num];
        payment.payable_amount = _amount;
        payment.start_date = now;
        payment.finish_date = _finish_date;
        payment.payment_number = payments_created.length;
        payment.payed = true;
        payment.sender = msg.sender;
        payment.receiver = _too;
        TOTAL_PAYMENTS_MADE = payments_created.length;
        payments_made.push(payment);
        payment_made[msg.sender][payment.payment_number] = payment;
        payed_too[payment.payment_number][payment.payable_amount] = _too;
        return success;
    }
    
    function getPayment(uint _payment) public view returns (uint, uint, uint, uint, uint, bool, address, address) {
        Payment memory payment = payments_made[_payment];
        return(payment.time,
               payment.payable_amount,
               payment.start_date,
               payment.finish_date,
               payment.payment_number,
               payment.payed,
               payment.sender,
               payment.receiver);
    }
    
    function changePaymentTerms(uint _payment, uint new_time, uint new_amount) public isAuthorized() returns (bool success) {
        checkCreatorValid(_payment);
        payments_created[_payment].time = new_time;
        payments_created[_payment].payable_amount = new_amount;
        return success;
    }
    
    function checkAddress(address _too) internal view {
        if (msg.sender == _too) {
            revert("The sender and receiver have the same address");
        }
    }
    
    function checkCreatorValid(uint _payment) internal view {
        require(payments_created[_payment].receiver == msg.sender,
                    "The creator of the payment is the address that will receive the payment");
    }
    
    function checkTimePeriod(uint _payment) internal view {
        require(payments_created[_payment].time >= 1 days, "Payment last for 1 day or longer");
        require(payments_created[_payment].time <= 30 days, "Payment last for no longer that 30 days");
    }
    
    function checkPaymentValid(uint _payment) internal view {
        require(payments_created[_payment].payed == false,
                    "The payment has not executed yet");
    }
    
    function checkPayableAmount(uint _amount, uint _payment) internal view {
        Payment storage pay = payments_created[_payment];
        require (pay.payable_amount == _amount, "The amount due against the payment is equal to the value being sent");
    }
 
}

contract InteractionFactory is BuildingFactory, Payments {
    
    uint public total_messages;
    uint public total_rules;
    
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
    
    mapping (address => mapping(uint => Message)) messages_sent;
    mapping (address => mapping(uint => Message)) messages_received;
    
    Rule[] public rules;
    
    function sendMessage(string memory _message, address too) public isActive() returns (bool msg_sent_success) {
        Message memory mess = Message((abi.encode(_message)), msg.sender, too);
        total_messages++;
        messages_sent[msg.sender][total_messages] = mess;
        messages_received[too][total_messages] = mess;
        return msg_sent_success;
    }
    
    function readMessage(uint _message) public view isActive() returns (bytes memory message) {
        return messages_received[msg.sender][_message].message;
    }
    
    function setNewRuling(string memory _rule, address[] memory _instructors, uint _buildNumber) public isOwnerOrManager(_buildNumber) returns (bool success) {
        address[] memory rule_instructors = _instructors;
        Rule memory newRule = Rule(_buildNumber, msg.sender, rule_instructors, (abi.encode(_rule)), true);
        rules.push(newRule);
        total_rules = rules.length;
        return success;
    }
    
}
