// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * A smart contract for an ERC=721 NFT with minting and admin roles.
 * @author Kevin Jones
 */
contract NFT is
    Initializable,
    OwnableUpgradeable,
    ERC721Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Events
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);
    event Withdraw(uint256 amount);
    event TokenMinted(address indexed to, uint256 indexed tokenId);

    constructor() {
        _disableInitializers();
    }

	/**
	 * Initialize the contract
	 * @param _owner The owner of the contract
	 * @param _minter The minter of the contract
	 */
    function initialize(address _owner, address _minter) public initializer {
        require(_owner != address(0), "Owner cannot be zero address");
        require(_minter != address(0), "Minter cannot be zero address");

        __Ownable_init();
        __AccessControl_init();
        __ERC721_init("NFT", "NFT");
        __Pausable_init();
        __ReentrancyGuard_init();

        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, _owner);
        _grantRole(MINTER_ROLE, _minter);
    }

    /**
     * Mint a credential
     * @param to The account to mint the credential to
     * @param tokenId The ID of the credential
     */
    function mint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(!_exists(tokenId), "Token already minted");
        
        _safeMint(to, tokenId);
        emit TokenMinted(to, tokenId);
    }

    /**
     * Add a minter
     * @param _account The account to add as a minter
     */
    function addMinter(address _account) public onlyRole(ADMIN_ROLE) {
        require(_account != address(0), "Cannot add zero address as minter");
        _grantRole(MINTER_ROLE, _account);
        emit MinterAdded(_account);
    }

    /**
     * Add an admin
     * @param _account The account to add as an admin
     */
    function addAdmin(address _account) public onlyRole(ADMIN_ROLE) {
        require(_account != address(0), "Cannot add zero address as admin");
        _grantRole(ADMIN_ROLE, _account);
        emit AdminAdded(_account);
    }

    /**
     * Remove an admin
     * @param _account The account to remove as an admin
     */
    function removeAdmin(address _account) public onlyRole(ADMIN_ROLE) {
        require(_account != owner(), "Cannot remove contract owner as admin");
        require(_account != _msgSender(), "Cannot remove self as admin");
        _revokeRole(ADMIN_ROLE, _account);
        emit AdminRemoved(_account);
    }

    /**
     * Remove a minter
     * @param _account The account to remove as a minter
     */
    function removeMinter(address _account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, _account);
        emit MinterRemoved(_account);
    }

    /**
     * Pause contract functions
     */
    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * Unpause contract functions
     */
    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * Function that allows the owner to withdraw ETH from the contract
     */
    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        emit Withdraw(balance);
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");
    }

    /**
     * Function that allows the contract to receive ETH
     */
    receive() external payable {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}