pragma solidity ^0.5.11;


library Strings {
    function equals(string storage self, string memory other) internal view returns (bool) {
        if (bytes(self).length != bytes(other).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(self)) == keccak256(abi.encodePacked(other));
        }
    }
}
