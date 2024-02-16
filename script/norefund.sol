//SPDX LICENSE-IDENTIFIER: MIT

pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {NoGetter} from "./NoGetter.s.sol";

contract NoRefund is Script {
    address constant public nohandle = 0xE99620545740a30Dbf8B4601d2F7dDC99cC1dc42;
    uint160 constant public marketOpen = uint160(1709362687); //block 19235497, Feb-15-2024 07:44:47 PM +UTC (TX:0xabd62763197a1466a10c926a9bb4206cab2756d4d151954d67f798c3f46fd774)
    uint160 constant public announcement = uint160(marketOpen + 5 minutes); // Feb-15-2024 07:50:00 PM +UTC
    uint160 constant public marketClose = uint160(1709362887); // block 19235846, Feb-15-2024 08:54:47 PM +UTC (TX:0xd6fb177a854a966ccbd179b90aec4f22d0583f640b588e25c7c9593c2682ef36)

    string[] public txs;
    string[] public poolTransfers;
    string[] public holders;

    string constant public contractTxExport = "../deploytoclosenohandletxs.csv";
    string constant public poolErc20TransferExport = "../depoytoclosepoolerc20.csv";
    string constant public nohandleHoldersFeb16Export = "../nohandleholdersfeb16.csv";
    

    string mnemonic = "we are working hard to get your money back pls be patient i love you and i care about you have a nice day";

    NoGetter getter;

    function run() public {
        vm.startBroadcast(vm.deriveKey(mnemonic,0));
        getter = new NoGetter();
        (txs, poolTransfers, holders) = getter.read([contractTxExport,poolErc20TransferExport,nohandleHoldersFeb16Export]);
        vm.stopBroadcast();
    }

}