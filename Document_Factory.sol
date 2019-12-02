pragma solidity ^0.5.12; 

contract DocumentFactory {
    
    uint Total_Documents;
    
    struct Doc {
        bytes32 doc_hash;
        mapping (address => address[]) sender_receivers;
        bool sent;
    }
    
    mapping (address => mapping(uint => Doc)) total_docs;
    mapping (address => bytes32) docs_linked;
    
    Doc[] public docs;
    
    function SendDoc(bytes32 _hash, address[] memory _recivers) public returns (bool success) {
        address[] memory sender_receivers = _recivers;
        Total_Documents++;
        Doc memory doc = Doc
    }
    
    
    
}
