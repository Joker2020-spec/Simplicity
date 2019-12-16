pragma solidity ^0.5.12; 

contract DocumentFactory {
    
    uint Total_Documents;
    
    struct Doc {
        bytes32 doc_hash;
        address sender;
        address[] recivers;
        bool sent;
    }
    
    mapping (address => mapping(uint => Doc)) sent_docs_linked;
    mapping (address => mapping(uint => mapping (bytes32 => address[]))) sender_receivers;
    
    
    mapping (address => bytes32) docs_linked;
    
    
    
    Doc[] public docs;
    
    function SendDoc(bytes32 _hash, address[] memory _recivers) public returns (bool success) {
        address[] memory _for = _recivers;
        uint this_doc = Total_Documents++;
        Doc memory doc = Doc({
            doc_hash: _hash,
            sender: msg.sender,
            recivers: _for,
            sent: true
        });
        sent_docs_linked[msg.sender][this_doc] = doc;
        sender_receivers[msg.sender][this_doc][_hash] = _for;
        docs.push(doc);
        return success;
    }
    
    function GetDoc(uint doc_num) public view returns (bytes32) {
        return(docs[doc_num].doc_hash);
    }
    
    function getDocComplete(uint doc_num) public view returns (bytes32, address, address[] memory, bool) {
        return(docs[doc_num].doc_hash, docs[doc_num].sender, docs[doc_num].recivers, docs[doc_num].sent);
    }
    
    function getRecivers(uint doc_num) public view returns (address[] memory) {
        return docs[doc_num].recivers;
    }
    
    function getDocAndRecivers(uint doc_num) public view returns (bytes32, address[] memory) {
        return(docs[doc_num].doc_hash, docs[doc_num].recivers);
    }
    
    function geTotaltDocReceivers(address sender, uint doc, bytes32 hash) public view returns (uint) {
        return sender_receivers[sender][doc][hash].length;
    }
    
    function getTotalDocs() public view returns (uint) {
        return Total_Documents;
    }
    
    
  
}
