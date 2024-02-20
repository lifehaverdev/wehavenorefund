// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, StdCheats} from "forge-std/Test.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";
import "./list.sol";
import "./testList.sol";

//dev
/*
This test is set up to sanity check the operations compared to the provided calculations and see how much gas they should cost to airdrop.
*/

contract CounterTest is Test {

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //MAINNET
    address constant tWETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; //SEPOLIA
    address constant gaslite = 0x09350F89e2D7B6e96bA730783c2d76137B045FEF; //MAINNET SEPOLIA
    uint256 constant WAD = 1000000000000000000;
    uint256 accounts = 718;
    address nodeployer = makeAddr("nodeployer");

    realPeople _list;
    realPeopleDeciMilli _testList;

    uint256 constant marketValueEth = 289138173027393030; //ETH/NO tx hash: 0x00283f10af7b2f50c73edef9c1fad5e8f5b47ea940629d8e7853132e430c2b87
    uint256 liquidityPool = 595452853383446971092;
    uint256 nOwe;    //1862_563415940294818815 MAIN
                     //    _186256341594029340 SEPOLIA
    uint256 ethGift; 

    bool test = false;

    address[] public addresses;
    uint256[] public amounts;

    function setUp() public {
        if(test){
            _testList = new realPeopleDeciMilli();
        }
        _list = new realPeople();
    }

    //how much gas does this cost
    function testairdropEighteenHundredFifty() public {
        vm.pauseGasMetering();
        _calculateAndReset(95); //price curve averaged fair market value +
        console2.log('NO Owed: ',nOwe);
        address weht;
        uint256 gasPrice;
        if(test){
            weht = tWETH;
            gasPrice = 2;
        } else {
            weht = WETH;
            gasPrice = 30;
        }
        uint256 gasUsed;
        startHoax(nodeployer,ethGift + 10 ether);
        address(weht).call{value: ethGift}(abi.encodeWithSignature("deposit()"));
        address(weht).call(abi.encodeWithSignature("approve(address,uint256)",gaslite,ethGift));
        vm.txGasPrice(gasPrice);
        vm.resumeGasMetering();
        gasUsed = gasleft();
        address(gaslite).call(abi.encodeWithSignature("airdropERC20(address,address[],uint256[],uint256)",weht, addresses, amounts, ethGift));
        gasUsed -= gasleft();
        console2.log('gas used ',gasUsed);
        console2.log('gas cost in eth ',gasUsed * gasPrice * 1000000000);
    }
    //1.021307050000000000 ETH at 50 gwei 
    //0.531079666000000000 ETH at 23 gwei
    //0.040852282000000000 ETH at 2 gwei (sepolia)


    function _calculateTotalAirdrop(uint256 _modif) internal {
        uint256 _gift;
        uint256 workingGift = FixedPointMathLib.fullMulDiv(marketValueEth, _modif, 10000);
            for(uint256 i = 0; i < accounts;){
                    addresses.push(_list.realPeopleAddresses(i));
                    if(test){
                        _gift = FixedPointMathLib.mulWad(_testList.decimillimatedNoHoldings(i),workingGift); //1e18 NO * 1e18 ETH/NO / 1e18 (ETH 1e18) / 10000 HENCE DECIMILLI
                        nOwe += _testList.decimillimatedNoHoldings(i);
                    } else {
                        _gift = FixedPointMathLib.mulWad(_list.realNoHoldings(i),workingGift); //1e18 NO * 1e18 ETH/NO / 1e18 (ETH 1e18) / 10000 HENCE DECIMILLI
                        nOwe += _list.realNoHoldings(i);
                    }
                    amounts.push(_gift);
                    ethGift += _gift;
                    unchecked{
                        ++i;
                    }
            }
            //RESET the array
            for(uint256 i=accounts; i>0;){
                addresses.pop();
                amounts.pop();
                unchecked {
                    --i;
                }
            }

    }

    function _calcAndReset(uint256 modif_) internal {
        _calculateTotalAirdrop(modif_);
        console2.log('price per token from market close percentage ',modif_ / 100);
        console2.log('eth Gift: ',ethGift / WAD); //CALCULATED DENOMINATION ETH
        ethGift = 0;
    }
}