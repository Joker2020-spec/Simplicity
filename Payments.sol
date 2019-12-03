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
    
    mapping (address => mapping(uint => Payment)) payments_made;
    mapping (uint => mapping(uint => address)) payed_too;
    
    function makePayment(uint _amount, uint _time, uint _finish_date, address _payee, address _too, bytes32 tx_id) public returns (bool success) {
        require (_finish_date > now && _finish_date > MIN_PAYMENT_TERMS);
        require (MAX_PAYMENT_TERMS >= _finish_date); 
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
        payments_made[msg.sender][_amount] = payment;
        payed_too[TOTAL_PAYMENTS_MADE][_amount] = _payee;
        return success;
    }
    
}
