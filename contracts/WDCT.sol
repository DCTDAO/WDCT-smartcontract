// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ECDSA.sol";


contract WDCT {
    string public name     = "Wrapped DCT";
    string public symbol   = "WDCT";
    uint8  public decimals = 18;
    
    uint256 private burnCounter = 0;
    uint256 public totalSupply = 0;
    
    address private owner;

    event  Approval(address indexed src, address indexed guy, uint256 wdct);
    event  Transfer(address indexed src, address indexed dst, uint256 wdct);
    event  Minted(address indexed src, uint256 wdct, uint256 id);
    event  Burned(address indexed src, uint256 wdct, uint256 id);
    
    mapping (address => uint256)                       public  balanceOf;
    mapping (address => mapping (address => uint256))  public  allowance;
    mapping (uint256 => bool)                          private mintedIds;
    
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    
    
    constructor() {
        owner = msg.sender;
    }
    
    
    function setOwner(address newOwner) public returns(bool){
        require(msg.sender == owner);
        owner = newOwner;
        return true;
    }
    
    
  
    
    function mint(uint256 wdct, uint256 id, uint deadline, Signature memory sign) public returns(bool) {
        require(deadline >= block.timestamp, 'WDCT: EXPIRED');
        require(mintedIds[id] == false, "You are using the same ID!!");
        bytes32 hash = keccak256(abi.encodePacked(
                                    wdct,
                                    id,
                                    deadline));
        hash = ECDSA.toEthSignedMessageHash(hash);
                                    
        require(ECDSA.recover(hash, sign.v, sign.r, sign.s) == owner, "Not owner: Invalid Signature");
        
        mintedIds[id] = true;
        
        balanceOf[msg.sender] += wdct;
        totalSupply+=wdct;
        emit Minted(msg.sender, wdct, id);
        return true;
    }
    
    function burn(uint256 wdct) public returns(bool) {
        require(balanceOf[msg.sender] >= wdct);
        balanceOf[msg.sender] -= wdct;
        totalSupply-=wdct;
        emit Burned(msg.sender, wdct, burnCounter);
        burnCounter++;
        return true;
    }
    
    
    
    function approve(address guy, uint256 wdct) public returns (bool) {
        allowance[msg.sender][guy] = wdct;
        emit Approval(msg.sender, guy, wdct);
        return true;
    }

    function transfer(address dst, uint256 wdct) public returns (bool) {
        return transferFrom(msg.sender, dst, wdct);
    }

    function transferFrom(address src, address dst, uint256 wdct)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wdct);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wdct);
            allowance[src][msg.sender] -= wdct;
        }

        balanceOf[src] -= wdct;
        balanceOf[dst] += wdct;

        emit Transfer(src, dst, wdct);

        return true;
    }
}
