# Example - How to integrate Oracle in your contract
(If you are a price consumer) then follow below steps)

explore https://oracles.goplugin.co & check which contract fulfils your requirement

- Deposit PLI by following the steps given in the UI(https://oracles.goplugin.co)
- copy the contract address 
- Check the "IntegrationSample.sol" program
- Paste the copied contract address in line number number 9
- Deploy this IntegrationSample.sol using Remix
- Call the function "getPriceInfo", this should trigger oracle contract and write the data in "currentValue"
- Call the function "show" to pull the current market price in your contract and go from there!
