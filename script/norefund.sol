//SPDX LICENSE-IDENTIFIER: MIT

pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {NoGetter} from "./NoGetter.s.sol";

contract NoRefund is Script {
    address constant public nohandle = 0xE99620545740a30Dbf8B4601d2F7dDC99cC1dc42;
    uint160 constant public marketOpen = uint160(1709362687); //block 19235497, Feb-15-2024 07:44:47 PM +UTC (TX:0xabd62763197a1466a10c926a9bb4206cab2756d4d151954d67f798c3f46fd774)
    uint160 constant public announcement = uint160(marketOpen + 5 minutes); // Feb-15-2024 07:50:00 PM +UTC
    uint160 constant public marketClose = uint160(1709362887); // block 19235846, Feb-15-2024 08:54:47 PM +UTC (TX:0xd6fb177a854a966ccbd179b90aec4f22d0583f640b588e25c7c9593c2682ef36)

    string[] public txsCSV;
    string[] public poolTransfersCSV;
    string[] public holdersCSV;

    string constant public contractTxExport = "../deploytoclosenohandletxs.csv";
    string constant public poolErc20TransferExport = "../depoytoclosepoolerc20.csv";
    string constant public nohandleHoldersFeb16Export = "../nohandleholdersfeb16.csv";

    address[] public allWallets;
    address[] public botWallets;
    address[] public pplWallets;

    uint256 public AllEthIn;
    uint256 public AllEthOut;
    uint256 public botEth;
    uint256 public pplEth;
    mapping(address => uint256) public EthIn;
    mapping(address => uint256) public Ethout;

    mapping(address => uint256) private touched;
    mapping(address => uint256) public holderSnapshot;

    

    string mnemonic = "we are working hard to get your money back pls be patient i love you and i care about you have a nice day";

    NoGetter getter;

    function run() public {
        //vm.startBroadcast(vm.deriveKey(mnemonic,0));
        //getter = new NoGetter();
        //(txs, poolTransfers, holders) = getter.read([contractTxExport,poolErc20TransferExport,nohandleHoldersFeb16Export]);
        //vm.stopBroadcast();

        //
        //general plan//
        //to calculate bot and ppl portion of pool
        //

        //read pool token transfers line by line
        //every line check the block number, add WETH transfers to pool to the AllEthIn and WETH transfers out to the AllEthOut, add the wallet to allWallets[], mark in the mapping touched, and add to the appropriate EthIn or EthOut mapping
        //if it is less than the announcement block number, add the wallet to botWallets[]. if after, add wallet to pplWallets[]

        //This can be checked by compairing the difference between AllEthIn and AllEthOut to the pulled liquidity ~595.45 (including fees, which belongs to project but can be used to increase refund effectiveness)

        //Calculate the bot Eth by iterating the botWallet[] address array and find the difference between EthIn and EthOut
        //Do the same for ppl

        //
        //
        //





    }

}