pragma solidity ^0.5.12;

import"./StateFactoryContract.sol";

contract PaymentContract {
    
    
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
        checkTimeValid(pay_num, _finish_date, _too);
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
         return true;
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
    
    function checkTimeValid(uint pay_num, uint finish_date, address _too) internal view {
        uint time_length = payment_info.payments_created[_too][pay_num].time;
        require(now + 5 minutes + time_length >= finish_date);
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
