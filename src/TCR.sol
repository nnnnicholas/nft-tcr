// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _totalSupply;
    uint256 private _mintFee;

    mapping(uint256 => uint256) public totalVotes;
    mapping(address => uint256) public vote;
    mapping(address => uint256) public balanceAtVote;

    address public tokenResolver;

    constructor(string memory name, string memory symbol, address _tokenResolver, uint256 mintFee) ERC721(name, symbol) {
        tokenResolver = _tokenResolver;
        _mintFee = mintFee;
    }

    function mint() public payable {
        require(msg.value == _mintFee, "Mint fee not paid");
        _totalSupply += 1;
        _safeMint(msg.sender, _totalSupply);
    }

    function setTokenResolver(address newTokenResolver) public onlyOwner {
        tokenResolver = newTokenResolver;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return ITokenResolver(tokenResolver).tokenURI(tokenId);
    }

    function resetVote() internal {
        address voter = msg.sender;
        uint256 projectId = vote[voter];
        if (projectId > 0) {
            uint256 voteBalance = balanceAtVote[voter];
            totalVotes[projectId] -= voteBalance;
            vote[voter] = 0;
            balanceAtVote[voter] = 0;
        }
    }

    function vote(uint256 projectId) public {
        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance > 0, "Insufficient balance");
        resetVote();
        totalVotes[projectId] += senderBalance;
        vote[msg.sender] = projectId;
        balanceAtVote[msg.sender] = senderBalance;
        transfer(address(this), senderBalance);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
    
        if (from != address(0) || to != address(0)) {
            resetVote();
        }
    }
}

interface ITokenResolver {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
