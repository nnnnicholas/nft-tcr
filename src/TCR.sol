// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {JBController} from "@jbx-protocol/juice-contracts-v3/contracts/JBController.sol";
import {JBFundingCycleData} from "@jbx-protocol/juice-contracts-v3/contracts/structs/JBFundingCycleData.sol";
import {JBFundAccessConstraints} from "@jbx-protocol/juice-contracts-v3/contracts/structs/JBFundAccessConstraints.sol";
import {JBFundingCycleMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/structs/JBFundingCycleMetadata.sol";
import {JBGroupedSplits} from "@jbx-protocol/juice-contracts-v3/contracts/structs/JBGroupedSplits.sol";
import {JBSplit} from "@jbx-protocol/juice-contracts-v3/contracts/structs/JBSplit.sol";
import {JBETHERC20ProjectPayer, JBTokens, IJBDirectory} from "@jbx-protocol/juice-contracts-v3/contracts/JBETHERC20ProjectPayer.sol";

contract NFTTCR is ERC721, JBETHERC20ProjectPayer {
    using Strings for uint256;

    event PeoplesChoiceChanged(uint256 newPeoplesChoice);
    event Vote(address voter, uint256 projectId);
    event TokenResolverUpdated(address newTokenResolver);
    event JBReconfigUpdated(JBReconfig newReconfig);
    event MintFeeUpdated(uint256 newMintFee);

    uint256 public totalSupply;
    uint256 public mintFee;
    uint256 public peoplesChoice;
    uint256 public treasuryId;
    IJBDirectory public dir;

    mapping(uint256 => uint256) public totalVotes;
    mapping(address => uint256) public votes;
    mapping(address => uint256) public balanceAtVote;

    address public tokenResolver;
    JBController public controller;

    struct JBReconfig {
        uint256 projectId;
        JBFundingCycleData data;
        JBFundingCycleMetadata metadata;
        uint256 mustStartAtOrAfter;
        JBGroupedSplits[] groupedSplits;
        JBFundAccessConstraints[] fundAccessConstraints;
        string memo;
    }

    JBReconfig public reconfig;

    constructor(
        string memory _name,
        string memory _symbol,
        address _tokenResolver,
        uint256 _mintFee,
        JBController _controller,
        JBReconfig memory _reconfig,
        uint256 _treasuryId,
        address _beneficiary,
        IJBDirectory _directory
    )
        ERC721(_name, _symbol)
        JBETHERC20ProjectPayer(
            _treasuryId,
            payable(_beneficiary),
            false,
            "Minted",
            "",
            false,
            _directory,
            address(this)
        )
    {
        tokenResolver = _tokenResolver;
        mintFee = _mintFee;
        controller = _controller;
        reconfig = _reconfig;
        treasuryId = _treasuryId;
        dir = _directory;
    }

    function mint() public payable {
        require(msg.value == mintFee, "Mint fee not paid");
        totalSupply += 1;
        _safeMint(msg.sender, totalSupply);
        _pay(
            treasuryId, //uint256 _projectId,`
            JBTokens.ETH, // address _token
            msg.value, //uint256 _amount,
            18, //uint256 _decimals,
            msg.sender, //address _beneficiary,
            0, //uint256 _minReturnedTokens,
            false, //bool _preferClaimedTokens,
            "Minted",
            "" //bytes calldata _metadata
        );
    }

    function setTokenResolver(address newTokenResolver) public onlyOwner {
        tokenResolver = newTokenResolver;
        emit TokenResolverUpdated(newTokenResolver);
    }

    function setMintFee(uint256 newMintFee) public onlyOwner {
        mintFee = newMintFee;
        emit MintFeeUpdated(newMintFee);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return ITokenResolver(tokenResolver).tokenURI(tokenId);
    }

    function resetVote() internal {
        address voter = msg.sender;
        uint256 projectId = votes[voter];
        if (projectId > 0) {
            uint256 voteBalance = balanceAtVote[voter];
            totalVotes[projectId] -= voteBalance;
            votes[voter] = 0;
            balanceAtVote[voter] = 0;
        }
    }

    function vote(uint256 projectId) public {
        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance > 0, "Insufficient balance");
        resetVote();
        totalVotes[projectId] += senderBalance;
        votes[msg.sender] = projectId;
        balanceAtVote[msg.sender] = senderBalance;
        emit Vote(msg.sender, projectId);
        if (totalVotes[projectId] > totalVotes[peoplesChoice]) {
            peoplesChoice = projectId;
            emit PeoplesChoiceChanged(projectId);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (from != address(0) || to != address(0)) {
            resetVote();
        }
    }

    function updateJuicebox() public {
        JBReconfig memory config = reconfig;
        config.groupedSplits[0].splits[0].projectId = peoplesChoice; // Update recepient based on TCR
        controller.reconfigureFundingCyclesOf(
            config.projectId,
            config.data,
            config.metadata,
            config.mustStartAtOrAfter,
            config.groupedSplits,
            config.fundAccessConstraints,
            config.memo
        );
        emit JBReconfigUpdated(config);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, JBETHERC20ProjectPayer)
        returns (bool)
    {
        return
            JBETHERC20ProjectPayer.supportsInterface(interfaceId) ||
            ERC721.supportsInterface(interfaceId);
    }
}

interface ITokenResolver {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
