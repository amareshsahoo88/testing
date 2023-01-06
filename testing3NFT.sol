// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol";

contract MyToken is ERC721, ERC721Burnable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter ;
    Counters.Counter private _mintByInstallmentCounter;

    uint256 public MINT_TRACKER;

    uint256 public Max_Token = 10000;   // Max supply

    uint256 listPrice = 0.01 ether;     //List price

    bool public allowMint;  

    bytes32 public merkelRoot ;  // root to be generated from a function            

    mapping(address => bool) public whitelistClaimed;
    

    constructor() ERC721("Zuraverse", "ZURA") {
        
    }

    // Main Minting Function 

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        require(tokenId<= Max_Token,"maximum limit reached");

        _safeMint(to, tokenId);
    }

    // Getter function for Listing price 

    function getListprice() public view returns (uint256) {
        return listPrice;
    }

    // Function for updating listing price

    function updateListPrice(uint256 _listPrice) public onlyOwner payable {
        listPrice = _listPrice;
    }

    // Function for re-allow minting after the installment is over

    function allowMinting(bool _allow) public onlyOwner{
        allowMint = _allow;

    }

    // function to set the max number of NFT to be minted in a particular installment

    function setMaxMint(uint _maxMints) external onlyOwner {
        require(_maxMints>0, "0 maxMints");
        uint256 currentTokenId = _tokenIdCounter.current();
        require(currentTokenId + _maxMints <= Max_Token, "overflow TOTAL_SUPPLY");
        MINT_TRACKER = _maxMints;
    }


    // General minting function

    
    // function NFT_Mint(address _to) public {
        
    //     _tokenIdCounter.increment();
    //     uint256 tokenId = _tokenIdCounter.current();
        
    //     require(tokenId<= 1000,"maximum limit reached");
       
    //     _safeMint(_to, tokenId);
        
        
    // }

    // function to mint Hack NFT - 3 installments of 3000 each

    function hackNFT_Mint(string memory tokenURI) public payable returns(uint){
        require(msg.value >= listPrice , "Send enough ether to list");

        _tokenIdCounter.increment();
        uint256 currentTokenId = _tokenIdCounter.current();

        //require(currentTokenId > 1000, "After 1000 mints"); // This function can be only called after 1k link

        assert(currentTokenId <= Max_Token);
        _mintByInstallmentCounter.increment();
        uint256 currentMintByInstallmentCounter = _mintByInstallmentCounter.current();

         if(currentMintByInstallmentCounter > MINT_TRACKER) {
            _mintByInstallmentCounter.reset();
            allowMint = false;
            revert("Mints disabled temporilly");
        }

         require(allowMint == true, "Mint not allowed");

         _safeMint(msg.sender,currentTokenId);

        
          return currentTokenId;

    }

    function mintInstallemntcounter() public view returns(uint){
        return _mintByInstallmentCounter.current();
    }


    // function to mint HACK NFT - 1st 1000 NFTs 

    // function whitelist_Hack_Mint(bytes32[] calldata _merkelproof) public {
    //     require(!whitelistClaimed[msg.sender],"Address has already claimed.");

    //     bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    //     require(MerkelProof.verify(_merkelProof , merkelRoot , leaf), "invalid proof.");

    //     whitelistClaimed[msg.sender] = true;

    //     NFT_Mint(msg.sender);

    // }






    // function to verify the whitelisted address


    // function verify(address _signer , string memory _message , bytes memory _sig)
    //     public pure returns(bool){
    //         bytes32 messageHash = getMessageHash(_message);
    //         bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        
    //         return recover(ethSignedMessageHash , _sig) == _signer;
            
    //         } 

    //         function getMessageHash(string memory _message) public pure returns (bytes32) {
    //             return keccak256(abi.encodePacked(_message));
    //         }

    //         function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    //             return keccak256(abi.encodePacked("\x19Ethereum Signed message:\n32",_messageHash));
    //         }

    //         function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns(address){
    //             (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
    //             return ecrecover(_ethSignedMessageHash, v , r ,s);
    //         }

    //         function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v){
    //             require(_sig.length == 65 , "invalid signature length");

    //             assembly{
    //                 r := mload(add(_sig, 32))
    //                 s := mload(add(_sig, 64))
    //                 v := byte(0, mload(add(_sig, 96)))
    //             }
    //         }







}
