pragma solidity ^0.5.12; 


contract DocumentFactory {
    
    
    uint Total_Documents;
    uint Valid_CheckPoints = 10;
    
    
    struct Doc {
        bytes32 doc_hash;
        address sender;
        address[] recivers;
        uint doc_number;
        uint checkPoints;
        bool sent;
    }
    
    
    mapping (address => mapping(uint => Doc)) sent_docs_linked;
    mapping (address => mapping(uint => mapping (bytes32 => address[]))) sender_receivers;
    
    
    
    Doc[] public docs;
    
    
    function SendDoc(bytes32 _hash, address[] memory _recivers) public returns (bool success) {
        address[] memory _for = _recivers;
        uint this_doc = Total_Documents++;
        Doc memory doc = Doc({
            doc_hash: _hash,
            sender: msg.sender,
            recivers: _for,
            doc_number: this_doc,
            checkPoints: 0,
            sent: true
        });
        sent_docs_linked[msg.sender][this_doc] = doc;
        sender_receivers[msg.sender][this_doc][_hash] = _for;
        docs.push(doc);
        return success;
    }
    
    function ValidateCheckPoint(uint doc_num) public returns (bool doc_checked) {
        CheckDocValid(doc_num);
        require (Valid_CheckPoints > docs[doc_num].checkPoints);
        for (uint i = 0; i < docs.length; i++) {
            if (doc_num == docs.length) {
                docs[doc_num].checkPoints + 1;
                doc_checked = true;
            }
        }
        return doc_checked;
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
    
    function getTotalDocReceivers(address sender, uint doc, bytes32 hash) public view returns (uint) {
        return sender_receivers[sender][doc][hash].length;
    }
    
    function getTotalDocs() public view returns (uint) {
        return Total_Documents;
    }
    
     function CheckDocValid(uint doc_num) internal {
        require (docs[doc_num].sent = true);
    }
    
    
}
