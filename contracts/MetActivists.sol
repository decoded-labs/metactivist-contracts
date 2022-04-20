// SPDX-License-Identifier: MIT
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ERC721AMock is ERC721A, Ownable {
    bytes32 public root;
    uint256 public immutable PRICE = 0.05 ether;
    uint256 public immutable PRESALE_DATE = 1650639600;
    uint256 public immutable PUBLIC_DATE = 1650697200;
    uint256 public immutable END_DATE = 1650718800;
    uint256 public immutable MAX_PER_WALLET = 5;

    mapping(address => uint256) public totalClaimed;

    constructor() ERC721A("MetActivists", "MetActivists") {}

    function reserveClaim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        require(
            _verify(_leaf(account, amount), proof),
            "Invalid merkle proof"
        );
        for (uint i; i < amount; i++){
            _safeMint(account, i);
        }
    }

    function activistMint(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external payable{
        require(
            _verify(_leaf(account, amount), proof),
            "Invalid merkle proof"
        );
        require(msg.value == (amount * PRICE), "Not correct amount.");
        for (uint i; i < amount; i++){
            _safeMint(account, totalMinted()+i);
        }
        totalClaimed[msg.sender] += amount;
    }

    function publicMint(uint256 _amount) external payable {
        require(totalClaimed[msg.sender] + _amount < MAX_PER_WALLET)

    };

    function _leaf(address _account, uint256 _tokenId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_tokenId, _account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(_proof, root, _leaf);
    }

    function setActivistRoot(bytes32 _root) external onlyOwner {
        root = _root;
    }

    function setReserveRoot(bytes32 _root) external onlyOwner {
        root = _root;
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
