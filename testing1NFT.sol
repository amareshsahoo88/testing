// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// importing hardhat and openzeppelin 
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// 

contract NFTMarketplace is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;     // counter for number of tokens minted
    Counters.Counter private _itemSold;     // counter for number of NFT sold
    Counters.Counter private _mintByInstallmentCounter;  // count for number of tokens minted in each installment

    uint256 listPrice = 0.01 ether;         // initial minting list price

    address private ZURA_NFT;

    uint public MINT_TRACKER; // This will reset after each installment

    uint constant TOTAL_SUPPLY = 10; 

    bool public allowMint = true;

//assigning the address msg.sender to the state variable owner and pre defining the NFT name and ticker
    constructor(address _zuraNft) ERC721("HackNFT","HACK") {
        ZURA_NFT = _zuraNft;
    }



// Declaring the structure for the attributes of the listed token
    // struct ListedToken {
    //     uint tokenId;
    //     address payable owner;
    //     address payable seller;
    //     uint256 price;
    //     bool currentlyListed;
    // }
// mapping the tokenid to the NFTs in the structure

    event NewToken(address user , uint tokenId , uint price);

   // mapping(uint256 => ListedToken) private idToListedToken;

    mapping(address => uint[]) private userOwnedNFTIds;

//this is a function that can be used in future to update or increase the initial minting price 

    function updateListPrice(uint256 _listPrice) public onlyOwner payable {
        listPrice = _listPrice;
    }

// this is a function that returns the current listing price for an NFT

    function getListprice() public view returns (uint256) {
        return listPrice;
    }

//fetch the latest tokenId that has been generated using the current token id

    // function getlatestIdToListedToken() public view returns(ListedToken memory) {
    //     uint256 currentTokenId = _tokenIds.current();
    //     return idToListedToken[currentTokenId];
    // }

// using the token id fetch the NFT linked to the token id - helpful to retrieve deta 
// from the frontend for a particular NFT

    // function getListedForTokenId(uint256 tokenId) public view returns(ListedToken memory) {
    //     return idToListedToken[tokenId];
    // }

//  getting the current tokenId so that to be used for minting a new NFT

    function getCurrentToken() public view returns(uint256){
        return _tokenIds.current();
    }

    function setMaxMint(uint _maxMints) external onlyOwner {
        require(_maxMints>0, "0 maxMints");
        uint256 currentTokenId = _tokenIds.current();
        require(currentTokenId + _maxMints <= TOTAL_SUPPLY, "overflow TOTAL_SUPPLY");
        MINT_TRACKER = _maxMints;
    }

    function allowMinting(bool _allow) public onlyOwner{
        allowMint = _allow;

    }

//  this is the token creation function . --> tokenURI and initial minting price is given
//  initial checks of the incoming ether for minting is done
//  token id is incremented
//  safemint function is used to mint the NFT













    function createToken(string memory tokenURI) public payable returns(uint){
        require(msg.value >= listPrice , "Send enough ether to list");
        //require(price>0 , "Make sure your price isn't negetive");
        
        _tokenIds.increment();
        uint256 currentTokenId = _tokenIds.current();

         _mintByInstallmentCounter.increment();
        currentMintByInstallmentCounter = _mintByInstallmentCounter.current();

        uint256 currentMintByInstallmentCounter = _mintByInstallmentCounter.current();

        //require(currentTokenId > 1000, "After 1000 mints"); // This function can be only called after 1k link

        assert(currentTokenId <= TOTAL_SUPPLY);

        

        
        
        if(currentMintByInstallmentCounter > MINT_TRACKER) {
            _mintByInstallmentCounter.reset();
            allowMint = false;
           // revert("Mints disabled temporilly");
        }

        require(allowMint == true, "Mint not allowed");

        _safeMint(msg.sender,currentTokenId);

        _setTokenURI(currentTokenId,tokenURI);

        userOwnedNFTIds[msg.sender].push(currentTokenId);

       // createListedToken(currentTokenId, price);

       emit NewToken(msg.sender , currentTokenId , msg.value);

        return currentTokenId;

    }










    function getter() public view returns(uint){
        uint256 currentMintByInstallmentCounter = _mintByInstallmentCounter.current();
        return currentMintByInstallmentCounter;
    }

    function getTokenIdValue() public view returns(uint){
        uint256 currentTokenId = _tokenIds.current();
        return currentTokenId;
    }

    function getMint_Tracker() public view returns(uint){
        return MINT_TRACKER;
    }

    // First 1000 mints
    // function giveAways(string[] memory tokenURI) external onlyOwner {

    //     for(uint i; i<tokenURI.length; i++) {

    //         _tokenIds.increment();
    //         uint256 currentTokenId = _tokenIds.current();

    //         require(currentTokenId <= 1000, "Only 1000 mints"); // This function can be only called after 1k link

    //         assert(currentTokenId <= TOTAL_SUPPLY);

    //         _safeMint(msg.sender,currentTokenId);

    //         _setTokenURI(currentTokenId,tokenURI[i]); 

    //         userOwnedNFTIds[msg.sender].push(currentTokenId);
    //     }
        
    // }

//  it is creating the listed token object . it updates the data in the struct which is accessed through mapping.

    // function createListedToken(uint256 tokenId, uint256 price) private {
    //     idToListedToken[tokenId] = ListedToken(
    //         tokenId,
    //         payable(address(this)),
    //         payable(msg.sender),
    //         price,
    //         true
    //     );
        //_transfer(msg.sender, address(this),tokenId);
   // }

//  This function shall be used by the frontend to retrieve all the NFT to be shownwhen it is requested

    // function getNFTByIds(uint[] calldata _nftIds) public view returns(ListedToken[] memory){
        
    //     ListedToken[] memory tokens = new ListedToken[](_nftIds.length);

    //     uint currentIndex = 0;

    //     for(uint i=0;i<_nftIds.length;i++){
    //         uint currentId = _nftIds[i];
    //         ListedToken storage currentItem = idToListedToken[currentId];
    //         tokens[currentIndex] = currentItem;
    //         currentIndex += 1;
    //     }
    //     return tokens;
    // }

    // function getNFTById(uint _nftId) public view returns(ListedToken memory){
    //     return idToListedToken[_nftId];
    // }

    function getNFTIdsOfUser(address _user) external view returns(uint[] memory) {
        return userOwnedNFTIds[_user];
    }

//  This function shall be used by fetch all the NFT held by a particular address

//     function getMyNFTs() public view returns(ListedToken[] memory){
//         uint totalItemCount = _tokenIds.current();
//         uint itemCount = 0;
//         uint currentIndex = 0;

// //  this for loop shall find the number of NFT
//         for(uint i = 0; i< totalItemCount; i++){
//             if(idToListedToken[i+1].owner==msg.sender || idToListedToken[i+1].seller == msg.sender){
//                 itemCount +=1;
//             }
//         }

//         ListedToken[] memory items = new ListedToken[](itemCount);

// //  this shall list the NFT

//         for(uint i=0 ; i< totalItemCount ; i++){
//             if(idToListedToken[i+1].owner==msg.sender || idToListedToken[i+1].seller == msg.sender){
//                 uint currentId = i+1;
//                 ListedToken storage currentItem = idToListedToken[currentId];
//                 items[currentIndex] = currentItem ;
//                 currentIndex +=1;
//             }
//         }
//         return items;
//     }

//  This function shall execute the sale at the marketplace when the seller is not the smartcontract it is a 3rd person

    // function executeSale(uint256 tokenId) public payable {
    //    uint price = idToListedToken[tokenId].price;
    //     require(msg.value == price , "please submit the asking price for the NFT in order to purchase");

    //     address seller = idToListedToken[tokenId].seller;

    //     idToListedToken[tokenId].currentlyListed = true;
    //     idToListedToken[tokenId].seller = payable(msg.sender);
    //     _itemSold.increment();

    //     _transfer(address(this), msg.sender , tokenId);

    //     approve(address(this) , tokenId);

    //     payable(owner()).transfer(listPrice);
    //     payable(seller).transfer(msg.value);

    // }

    function burn(uint256 tokenId) external virtual {
        require(msg.sender == ZURA_NFT, "only ZURA_NFT");
        _burn(tokenId);
    }

    function setZURA_NFT(address _ZURA_NFT) external onlyOwner {
        ZURA_NFT = _ZURA_NFT;
    }


}