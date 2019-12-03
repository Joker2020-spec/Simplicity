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
        address payer;
        address payee;
    }
    
    Payment[] payments_made;
    Payment[] payments_created;
    
    mapping (address => mapping(uint => Payment)) payment_made;
    mapping (uint => mapping(uint => address)) payed_too;
    
    function createPayment(uint _amount, uint _time, address _sender) public returns (bool success) {
       // require (_finish_date > now && _finish_date > MIN_PAYMENT_TERMS, "Payment must be for a longer period than 1 day");
       //require (MAX_PAYMENT_TERMS >= _finish_date, "Must not be more than 30 days untill next payment, if due"); 
        TOTAL_PAYMENTS_CREATED + 1;
        Payment memory payment = Payment({
            time: _time, 
            payable_amount: _amount, 
            start_date: 0, 
            finish_date: 0, 
            payment_number: TOTAL_PAYMENTS_CREATED, 
            payed: false, 
            payer: _sender,
            payee: msg.sender
        });
        payments_created.push(payment);
        return success;
    }
    
    function getPaymentTerms(uint _payment) public view returns (uint, uint, uint, uint) {
        return(payments_created[_payment].time,
               payments_created[_payment].payable_amount,
               payments_created[_payment].start_date,
               payments_created[_payment].finish_date);
    }
    
    function makePayment(uint pay_num, uint amount, uint _time, uint _finish_date, address _too) public returns (bool success) {
        Payment storage pay = payments_created[pay_num];
        pay.start_date = now;
        pay.finish_date = _finish_date;
        pay.payment_number = TOTAL_PAYMENTS_MADE;
        pay.payed = true;
        pay.payer = msg.sender;
        pay.payee = _too;
        
    }
}
