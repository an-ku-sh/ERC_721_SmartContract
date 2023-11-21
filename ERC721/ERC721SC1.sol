// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721SC1 is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;

    //Supply Limits
    uint256 maxSupply = 1000; 
    uint256 allowListMaxSupply = 1000; 
    //The allowlist
    mapping (address => bool) public allowList; 

    //Supply states
    bool public publicMintOpen = false; 
    bool public allowListMintOpen = false; 

    //custom NFT Metadata 
    string public ipfsUri; 

    constructor(address initialOwner)
        ERC721("ERC721SC1", "SC1")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        // return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
        return  "ipfs://QmSXRv4vUeTEp4Q3EhNbpmXU9BCC5WzyY3fZrKgwyvwSgK/";
    }
 

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    
    //here the NFT is minted by the owner only
    // function safeMint(address to) public onlyOwner {
    //     uint256 tokenId = _nextTokenId++;
    //     _safeMint(to, tokenId); 
    // }
    
    //Functionality to change state of mint window open/closed
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen; 
        allowListMintOpen = _allowListMintOpen; 
    }

    //here the NFT is minted by the public
    function publicMint() public payable { 
        require(publicMintOpen, "Public Mint Not OPen");
        require(msg.value == 0.001 ether, "Not ENough Funds");  //payable allows to accept payments
        //total supply = no of NFTs minted so far
        require(totalSupply() < maxSupply, "Sold Out!"); 
        // uint256 tokenId = _nextTokenId++;
        // _safeMint(msg.sender, tokenId);
        internalMint();
    }
    
    //here NFT is minted exclusively by members of Allow-List
    function allowListMint() public payable{
        require(allowList[msg.sender], "You r not on the list");
        require(allowListMintOpen, "Allow list Mint not open");
        require(msg.value == 0.001 ether, "Not ENough Funds");  //payable allows to accept payments
        //total supply = no of NFTs minted so far
        require(totalSupply() < allowListMaxSupply, "Sold Out!"); 
        // uint256 tokenId = _nextTokenId++;
        // _safeMint(msg.sender, tokenId);
        internalMint();
    }
    
    //internal function to clean up code
    function internalMint() internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    //Function to add members to the allow list
    function setAllowlist(address[] calldata addresses) external onlyOwner(){
        for(uint256 i =0; i < addresses.length; i++){
            allowList[addresses[i]] = true; 
        }
    }
    
    //Function to withdraw funds 
    function withdrawFunds(address _address) external  onlyOwner{
        //get the balance of the contract 
        uint256 balance = address(this).balance; 
        payable(_address).transfer(balance); 
    }



    // The following functions are overrides required by Solidity.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
