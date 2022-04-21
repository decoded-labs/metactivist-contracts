// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract METActivists is ERC721A, Ownable {

    bytes32 public rootActivist;
    bytes32 public rootReserve;
    uint256 public immutable ACTIVIST_PRICE = 0.05 ether;
    uint256 public immutable PUBLIC_PRICE = 0.07 ether;
    uint256 public immutable PRESALE_DATE = 1650639600;
    uint256 public immutable PUBLIC_DATE = 1650697200;
    uint256 public immutable END_DATE = 1650718800;
    uint256 public immutable MAX_PER_WALLET = 5;
    uint256 public immutable MAX_AMOUNT = 789;
    uint256 public immutable SOFT_CAP = 700;
    address public immutable PROXY_REGISTRY = 0x1E525EEAF261cA41b809884CBDE9DD9E1619573A;

    uint256 public totalClaimed;
    mapping(address => uint256) public totalActivistMint;

    string public baseURI_ = "https://gateway.pinata.cloud/ipfs/QmakkM1At3uxQgkUZa8xtaTkAX76nLQQbPgjJu8QZkCL2v";
    bool public revealed = false;

    constructor() ERC721A("METActivists", "METActivists") {}

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    // states: 0="Presale", 1="Public sale", 2="Sale over"
    function getState () public view returns(uint256 state) {
        if(block.timestamp > END_DATE) {
            state = 2;
        } else if (block.timestamp < END_DATE && block.timestamp > PUBLIC_DATE) {
            state = 1;
        } else if (block.timestamp < PUBLIC_DATE && block.timestamp > PRESALE_DATE) {
            state = 0;
        }
    }

    function reserveClaim(
        uint256 _amount,
        bytes32[] calldata _proof
    ) external {
        require(_verify(_leaf(msg.sender, _amount), rootReserve, _proof),"Invalid merkle proof");
        require(getState() == 0, "Not my tempo");
        _safeMint(msg.sender, _amount);
        totalClaimed += _amount;
    }

    function activistMint(
        uint256 _amount,
        bytes32[] calldata _proof
    ) external payable{
        require(_verify(_leaf(msg.sender, _amount), rootActivist, _proof),"Invalid merkle proof");
        require(msg.value == (_amount * ACTIVIST_PRICE), "Wrong amount.");
        require(getState() == 0, "Not my tempo");
        uint256 desired = totalMinted() + _amount;
        uint256 threshold = SOFT_CAP + totalClaimed; 
        require(desired < threshold,"Can't grab reserved assets");
        _safeMint(msg.sender, _amount);
        totalActivistMint[msg.sender] += _amount;
    }

    function publicMint(uint256 _amount) external payable {
        require(_amount < MAX_PER_WALLET, "Only 5 per tx");
        require(msg.value == (_amount * PUBLIC_PRICE), "Wrong amount");
        require(getState() == 1, "Not my tempo");
        _safeMint(msg.sender, _amount);
        
    }

    function _leaf(address _account, uint256 _tokenId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_tokenId, _account));
    }

    function _verify(bytes32 leaf, bytes32 _root, bytes32[] memory _proof)
        internal
        pure
        returns (bool)
    {
        return MerkleProof.verify(_proof, _root, leaf);
    }

    function setActivistRoot(bytes32 _root) external onlyOwner {
        rootActivist = _root;
    }

    function setReserveRoot(bytes32 _root) external onlyOwner {
        rootReserve = _root;
    }


    function numberMinted(address _owner) public view returns (uint256) {
        return _numberMinted(_owner);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function getAux(address _owner) public view returns (uint64) {
        return _getAux(_owner);
    }

    function setAux(address _owner, uint64 _aux) public {
        _setAux(_owner, _aux);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (revealed == false){
            return baseURI_;
        } else {
            return super.tokenURI(tokenId);
        }
    }


    function reveal (string memory __baseURI) external onlyOwner {
        require(revealed == false, "It's been revealed already.");
        baseURI_ = __baseURI;
        revealed = true;
    }

    
    function exists(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function burn(uint256 _tokenId, bool _approvalCheck) public {
        _burn(_tokenId, _approvalCheck);
    }

    function isApprovedForAll(address _owner, address operator) public view override returns (bool) {
        OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(PROXY_REGISTRY);
        if (address(proxyRegistry.proxies(_owner)) == operator) return true;
        return super.isApprovedForAll(_owner, operator);
    }
}

contract OwnableDelegateProxy { }
contract OpenSeaProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}