pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import"./Untitled1.sol";

contract Payments is TenantFactory {
    
    
    uint NON_PAYMENT = 0;
    uint TOTAL_PAYMENTS_MADE = 0;
    uint TOTAL_PAYMENTS_CREATED = 0;
    uint MAX_PAYMENT_TERMS = 30 days;
    uint MIN_PAYMENT_TERMS = 1 days;
    
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
    
    function createPayment(uint _amount, uint _time) public returns (bool success) {
        Payment memory payment = Payment({
            time: _time, 
            payable_amount: _amount, 
            start_date: 0, 
            finish_date: 0, 
            payment_number: TOTAL_PAYMENTS_CREATED + 1, 
            payed: false, 
            sender: address(0),
            receiver: msg.sender
        });
        TOTAL_PAYMENTS_CREATED + 1;
        payments_created.push(payment);
        return success;
    }
    
    function getPaymentTerms(uint _payment) public view returns (uint, uint, uint, uint) {
        return(payments_created[_payment].time,
               payments_created[_payment].payable_amount,
               payments_created[_payment].start_date,
               payments_created[_payment].finish_date);
    }
    
    function makePayment(uint _amount, uint pay_num, uint _finish_date, address _too) public returns (bool success) {
        checkAddress(_too);
        checkTimePeriod(pay_num);
        Payment storage payment = payments_created[pay_num];
        payment.payable_amount = _amount;
        payment.start_date = now;
        payment.finish_date = _finish_date;
        payment.payment_number = TOTAL_PAYMENTS_MADE + 1;
        payment.payed = true;
        payment.sender = msg.sender;
        payment.receiver = _too;
        TOTAL_PAYMENTS_MADE = payment.payment_number;
        payments_made.push(payment);
        payment_made[msg.sender][payment.payment_number] = payment;
        payed_too[payment.payment_number][payment.payable_amount] = _too;
        return success;
    }
    
    function changePaymentTerms(uint _payment, uint new_time, uint new_amount) public returns (bool success) {
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
        require(payments_created[_payment].receiver == msg.sender);
    }
    
    function checkTimePeriod(uint _payment) internal view {
        require(payments_created[_payment].time > 1 days);
        require(payments_created[_payment].time <= 30 days);
    }
    
    function checkPayableAmount(uint _amount, uint _payment, address _too) internal view returns (bool) {
        Payment storage pay = payments_created[_payment];
        require (pay.payable_amount == _amount);
        for (uint i = 0; i < list_of_tenants.length; i++) {
            if (list_of_tenants[i].rent_charge == _amount) {
                require (list_of_tenants[i].rent_charge == _amount);
            }
        }
    }
 
}
