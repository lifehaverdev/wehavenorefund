//SPDX LICENSE-IDENTIFIER: MIT

pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";

contract NoGetter is Script {

    function read(string[] calldata data) public returns (string[] memory outputs){
        string[] memory outputs;
        outputs[0] = vm.readFile(data[0]);
        outputs[1] = vm.readFile(data[1]);
        outputs[2] = vm.readFile(data[2]);
        return outputs;
    }

}