# DataFeed Repository
(If you are a node operator, please ensure you are following all the steps)
### Step 1 - You should have a valid Oracle address deployed
### Step 2 - You should have a valid JobID setup in your node
### Step 3 - You should have called "fullFillment" method with your node address

It has two folder
- contracts (Step 4)
- adapter   (Step 5)

### Step 4
Contracts folder contains two contract, but datafeed provider should run & deploy "InternalContract" only.

InternalContract.sol requires following params are input while deploying
- _pli (0xff7412ea7c8445c46a8254dfb557ac1e48094391 - Fixed)
- _oracle (to be setup by Node Operator or data feed provider)
- _jobid (to be setup by the Node operator or data feed provider)

Line number 72 & 73 should be updated with the right index pair to provide pricing for defi-application

```
    req.add("_fsysm","XDC");
    req.add("_tsysm","USDT");
```
Once this contract is deployed using "remix" or "truffle" or "hardhat"(your preferred way of deployment). You can proceed to next step

### Step 5 - How to run Adapter
```
cd adapter
npm install
npm start
```
localhost will listed in 5001 port number, you can change this as required

### Step 6 - You should have enabled this bridge in your plugin node to listen

### Step 7 - Test your contract before you submit the details in https://oracles.goplugin.co
- To test, if your contract is working fine
- Send just 1 PLI to your contract address(obtained from Step 4 deployment)
- call testMyFunc() function, it should return successfull transaction