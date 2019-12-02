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
        bool payed;
        address payer;
    }
    
    mapping (address => mapping(uint => Payment)) payments_made;
    mapping (uint => address) payed_too;
    
    function makePayment(uint _amount, uint _time, uint _finish_date, address _payee) public returns (bool success) {
        require (_finish_date > now && _finish_date > 1 days);
        Payment memory payment = Payment({time: _time, payable_amount: _amount, start_date: now, finish_date: _finish_date, payed: true, payer: msg.sender});
        payments_made[msg.sender][_amount] = payment;
        payed_too[_amount] = _payee;
        TOTAL_PAYMENTS_MADE + 1;
        return success;
    }
    
}
