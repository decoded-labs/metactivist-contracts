// SPDX-License-Identifier: MIT
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ERC721AMock is ERC721A, Ownable {
    bytes32 public rootActivist;
    bytes32 public rootReserve;
    uint256 public immutable ACTIVIST_PRICE = 0.05 ether;
    uint256 public immutable PUBLIC_PRICE = 0.07 ether;
    uint256 public immutable PRESALE_DATE = 1650639600;
    uint256 public immutable PUBLIC_DATE = 1650697200;
    uint256 public immutable END_DATE = 1650718800;
    uint256 public immutable MAX_PER_WALLET = 5;
    uint256 public immutable MAX_AMOUNT = 789;

    mapping(address => uint256) public totalClaimed;
    mapping(address => uint256) public totalActivistMint;

    constructor() ERC721A("METActivists", "METActivists") {}

    function reserveClaim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        require(_verify(_leaf(account, amount), rootReserve, proof),"Invalid merkle proof");
        for (uint i; i < amount; i++){
            _safeMint(account, i);
        }
        totalClaimed[msg.sender] += amount;
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

    function activistMint(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external payable{
        require(
            _verify(_leaf(account, amount), rootActivist, proof),
            "Invalid merkle proof"
        );
        require(msg.value == (amount * ACTIVIST_PRICE), "Not correct amount.");
        for (uint i; i < amount; i++){
            _safeMint(account, totalMinted()+i);
        }
        totalActivistMint[msg.sender] += amount;
    }

    function publicMint(uint256 _amount) external payable {
        require(_amount < MAX_PER_WALLET);
        

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

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function safeMint(address _to, uint256 _quantity) public {
        _safeMint(_to, _quantity);
    }

    function safeMint(
        address _to,
        uint256 _quantity,
        bytes memory _data
    ) public {
        _safeMint(_to, _quantity, _data);
    }

    function mint(address _to, uint256 _quantity) public {
        _mint(_to, _quantity);
    }

    function burn(uint256 _tokenId, bool _approvalCheck) public {
        _burn(_tokenId, _approvalCheck);
    }
}
