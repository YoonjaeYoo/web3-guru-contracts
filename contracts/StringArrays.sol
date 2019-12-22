pragma solidity ^0.5.11;

import "./Strings.sol";


library StringArrays {
    using Strings for string;

    function insertFirst(string[] storage self, string memory str) public {
        self.length += 1;
        for (uint i = self.length - 1; i >= 1; i--) {
            self[i] = self[i - 1];
        }
        self[0] = str;
    }

    function remove(string[] storage self, string memory str) public returns (bool) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i].equals(str)) {
                for (uint j = i; j < self.length - 1; j++) {
                    self[j] = self[j + 1];
                }
                self.length -= 1;
                return true;
            }
        }
        return false;
    }

    function includes(string[] storage self, string memory str) public view returns (bool) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i].equals(str)) {
                return true;
            }
        }
        return false;
    }
}
