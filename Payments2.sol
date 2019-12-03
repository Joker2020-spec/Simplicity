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
    
    function createPayment(uint _amount, uint _time) public returns (bool success) {
        Payment memory payment = Payment({
            time: _time, 
            payable_amount: _amount, 
            start_date: 0, 
            finish_date: 0, 
            payment_number: TOTAL_PAYMENTS_CREATED + 1, 
            payed: false, 
            payer: address(0),
            payee: msg.sender
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
    
    function makePayment(uint pay_num, uint _finish_date, address _too) public returns (bool success) {
        checkAddress(_too);
        Payment storage pay = payments_created[pay_num];
        pay.start_date = now;
        pay.finish_date = _finish_date;
        pay.payment_number = TOTAL_PAYMENTS_MADE + 1;
        pay.payed = true;
        pay.payer = msg.sender;
        pay.payee = _too;
        TOTAL_PAYMENTS_MADE = pay.payment_number;
        payments_made.push(pay);
        payment_made[msg.sender][pay.payment_number] = pay;
        payed_too[pay.payment_number][pay.payable_amount] = _too;
        return success;
    }
    
    function checkAddress(address _too) internal view {
        if (msg.sender == _too) {
            revert("The sender and receiver have the same address");
        }
    }
    
}
