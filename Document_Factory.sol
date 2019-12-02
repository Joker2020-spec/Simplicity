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
        Doc memory doc = Doc({
            doc_hash: _hash,
            sent: true
        });
        
    }
  
}











pragma solidity ^0.5.12; 

library DocumentFactory {

    
    struct Doc {
        bytes32 doc_hash;
        mapping (address => address[]) sender_receivers;
        bool sent;
    }
    
    struct Attachments {
        mapping (address => mapping(uint => Doc)) total_docs;
        mapping (address => bytes32) docs_linked;
    }
    
    struct Store {
        Doc[] docs;
        uint Total_Documents;
    }
    
    function SendDoc(Doc storage doc, Attachments storage attach, Store storage plus, bytes32 _hash, address[] memory _recivers) public returns (bool success) {
        address[] memory too = _recivers;
        doc.doc_hash = _hash;
        doc.sender_receivers[msg.sender].push(too);
        
    
    }
    
    function Addition(Store storage plus, Doc storage doc) public {
        plus.Total_Documents++;
    }
  
}
