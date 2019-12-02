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
    
    function GetDoc(uint doc_num) public view returns (bytes32) {
        return(docs[doc_num].doc_hash);
    }
  
}
