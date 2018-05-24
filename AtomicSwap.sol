pragma solidity ^0.4.24;

contract AtomicSwap {

  address receiver;
  address owner;
  bytes hash;
  uint timelocked;
  
  event contract_locked();
  event secret_revelared();
  event secret_wrong(bytes20);

  constructor(address _receiver, string _hash, uint _hours) public {
    receiver = _receiver;
    hash = fromHex(_hash);
    timelocked = now + (_hours * 1 hours);
    owner = msg.sender;
  }

  function redeem(string _secret) public {
    if(isLocked()){
        emit contract_locked();
    } else {
      bytes20 hash_redeem = ripemd160(fromHex(_secret));
      if(isValidHash(hash_redeem)){
        emit secret_revelared();
        selfdestruct(receiver);
      } else {
        emit secret_wrong(hash_redeem);
      } 
    }
    
  }

  function refund() public {
    require(isLocked());
    selfdestruct(owner);
  }

  function () payable public {}

  function getReceiver() public constant returns (address) {
    return receiver;
  }

  function isLocked() public constant returns (bool) {
    return (timelocked < now);
  }

  function getHash() public constant returns (bytes) {
    return hash;
  }

  function fromHexChar(uint c) private pure returns (uint) {
    if (byte(c) >= byte('0') && byte(c) <= byte('9')) {
      return c - uint(byte('0'));
    }
    if (byte(c) >= byte('a') && byte(c) <= byte('f')) {
      return 10 + c - uint(byte('a'));
    }
    if (byte(c) >= byte('A') && byte(c) <= byte('F')) {
      return 10 + c - uint(byte('A'));
    }
  }

  function fromHex(string s) private pure returns (bytes) {
    bytes memory ss = bytes(s);
    require(ss.length%2 == 0); // length must be even
    bytes memory r = new bytes(ss.length/2);
    for (uint i=0; i<ss.length/2; ++i) {
      r[i] = byte(fromHexChar(uint(ss[2*i])) * 16 +
                  fromHexChar(uint(ss[2*i+1])));
    }
    return r;
  }

  function isValidHash(bytes20 hash_sended) private view returns (bool) {
    bool r = true;
    for (uint i=1; i<=20; ++i) {
      if(hash_sended[hash_sended.length - i] != hash[hash.length - i]){
        return false;
      }
    }
    return r;
  }

}


