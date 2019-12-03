pragma solidity ^0.5.12;

import"./Untitled1.sol";

contract Payments is TenantFactory {
    
    uint NON_PAYMENT = 0;
    uint TOTAL_PAYMENTS_MADE = 0;
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
        bytes32 tx_hash;
    }
    
    Payment[] payments;
    
    mapping (address => mapping(uint => Payment)) payments_made;
    mapping (uint => mapping(uint => address)) payed_too;
    
    function makePayment(uint _amount, uint _time, uint _finish_date, address _too, bytes32 tx_id) public returns (bool success) {
        require (_finish_date > now && _finish_date > MIN_PAYMENT_TERMS, "Payment must be for a longer period than 1 day");
        require (MAX_PAYMENT_TERMS >= _finish_date, "Must not be more than 30 days untill next payment, if due"); 
        TOTAL_PAYMENTS_MADE + 1;
        Payment memory payment = Payment({
            time: _time, 
            payable_amount: _amount, 
            start_date: now, 
            finish_date: _finish_date, 
            payment_number: TOTAL_PAYMENTS_MADE, 
            payed: true, 
            payer: msg.sender,
            payee: _too,
            tx_hash: tx_id
        });
        payments_made[msg.sender][TOTAL_PAYMENTS_MADE] = payment;
        payed_too[TOTAL_PAYMENTS_MADE][_amount] = _too;
        return success;
    }
    
    function getPayment(uint _payment) public view returns (bytes32 tx_hash) {
        return(payments[_payment].tx_hash);
    }
    
}
