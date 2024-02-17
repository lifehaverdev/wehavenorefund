const fs = require('fs');
const readline = require('readline');

const announcementBlockNumber = 19235523;
const poolAddress = "0x945295d8efe2b63ad5a9239ac5c1b4d28e90bb7c";
const etherscanExportCSV = 'deploytoclosepoolerc20.csv'

let allTx = {};
let targets = {};
let bots = 0;
let ppl = 0;

// Function to parse CSV line
function parseCSVLine(line) {
    return line.split(',').map(entry => entry.trim());
}

// Read CSV file line by line
const rl = readline.createInterface({
    input: fs.createReadStream(etherscanExportCSV), // Provide path to your CSV file
    crlfDelay: Infinity
});

// Skip the header line
let isFirstLine = true;

//NO flow check
rl.on('line', (line) => {
    if (isFirstLine) {
        // Skip the header line
        isFirstLine = false;
        return;
    }
    // Parse CSV line
    const [tx, blockNumber, time, UTC, from, to, tokenValue, valueUSD, CA, TokenName, tokenSymbol] = parseCSVLine(line);
    let value = parseFloat(tokenValue);
    let NOTransfer = tokenSymbol == 'NO'
    let buy = from == poolAddress;

    if(buy){value = -value} //comes out of pool
    // Update targets object and NO flows
    if(NOTransfer){
        if(!allTx[tx]){
            allTx[tx] = {
                WETHflow: 0,
                NOflow: value
            }
        }else{
            allTx[tx].NOflow += value;
        }
        if (!targets[to]) {
            targets[to] = {
                firstBlock: blockNumber,
                WETHflow: 0,
                NOflow: -value,
                beforeAnnouncement: parseInt(blockNumber) < announcementBlockNumber
            };
        } else {
            targets[to].NOflow -= value;
        }
    }
});

rl.on('close', () => {
    firstLine = true;
    // Read CSV file again for WETH flows
    const rl2 = readline.createInterface({
        input: fs.createReadStream(etherscanExportCSV),
        crlfDelay: Infinity
    });

    rl2.on('line', (line) => {

        if (isFirstLine) {
            // Skip the header line
            isFirstLine = false;
            return;
        }

        // Parse CSV line
        const [tx, blockNumber, time, UTC, from, to, tokenValue, valueUSD, CA, TokenName, tokenSymbol] = parseCSVLine(line);
        let value = parseFloat(tokenValue);
        let WETHTransfer = tokenSymbol == 'WETH'
        let sell = from == poolAddress;
        
        if(sell){value = -value} //goes out of pool
        
        if(WETHTransfer){
            if(!allTx[tx]){
                allTx[tx] = {
                    WETHflow: value,
                    NOflow: 0
                }
            }else{
                allTx[tx].WETHFlow += value;
            }
            if (!targets[from]) {
                targets[from] = {
                    firstBlock: blockNumber,
                    WETHflow: -value,
                    NOflow: 0,
                    beforeAnnouncement: parseInt(blockNumber) < announcementBlockNumber
                };
            } else {
                targets[from].WETHflow -= value;
            }
            
        }
        
    });

rl2.on('close', () => {
        let botEthIn = 0;
        let botEthOut = 0;
        let pplEthIn = 0;
        let pplEthOut = 0;
        let botNoIn = 0;
        let botNoOut = 0;
        let pplNoIn = 0;
        let pplNoOut = 0;

        // Calculate bot and ppl portions
        Object.values(targets).forEach(target => {
            if (target.beforeAnnouncement) {
                bots++;
                if (target.WETHflow > 0) {
                    botEthOut += target.WETHflow;
                } else {
                    botEthIn -= target.WETHflow;
                }
                if (target.NOflow > 0){
                    botNoOut += target.NOflow;
                } else {
                    botNoIn -= target.NOflow;
                }
            } else {
                ppl++;
                if (target.WETHflow > 0) {
                    pplEthOut += target.WETHflow;
                } else if (target.WETHflow < 0) {
                    pplEthIn -= target.WETHflow;
                }
                if (target.NOflow > 0) {
                    pplNoOut += target.NOflow;
                } else if (target.NOflow < 0) {
                    pplNoIn -= target.NOflow;
                }
            }
        });
        console.log('bots: ',bots);
        console.log('ppl: ',ppl);
        console.log('Bot Eth in:', botEthIn);
        console.log('Bot Eth out:', botEthOut);
        console.log('Ppl Eth in:', pplEthIn);
        console.log('Ppl Eth out:', pplEthOut);
        console.log('Bot No in:', botNoIn);
        console.log('Bot No out:', botNoOut);
        console.log('Ppl No in:', pplNoIn);
        console.log('Ppl No out:', pplNoOut);
        //console.log(targets)
        console.log('pot', botEthIn - botEthOut + pplEthIn - pplEthOut)
        console.log('No', botNoIn - botNoOut + pplNoIn - pplNoOut)
    });
});
