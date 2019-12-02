pragma solidity ^0.5.12; 

contract DocumentFactory {
    
    uint Total_Documents;
    
    struct Doc {
        bytes32 doc_hash;
        address[] recivers;
        bool sent;
    }
    
    mapping (address => mapping(uint => Doc)) sent_docs_linked;
    
    
    mapping (address => bytes32) docs_linked;
    mapping (address => address[]) sender_receiver;
    
    
    Doc[] public docs;
    
    function SendDoc(bytes32 _hash, address[] memory _recivers) public returns (bool success) {
        address[] memory too_from = _recivers;
        uint this_doc = Total_Documents++;
        Doc memory doc = Doc({
            doc_hash: _hash,
            recivers: too_from,
            sent: true
        });
        sent_docs_linked[msg.sender][this_doc] = doc;
        docs.push(doc);
        return success;
    }
    
    function GetDoc(uint doc_num) public view returns (bytes32 doc_hash) {
        for (uint i = 0; i < docs.length; i++) {
            if (docs.length == doc_num) {
                Doc storage d = docs[doc_num];
                doc_hash = d.doc_hash;
                return doc_hash;
            }
        }
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
