# SmartEnergy
![](Figures/one_pager.jpg?raw=true "Optional Title")


![](Figures/iot_architecture.jpg?raw=true "Optional Title")

![](Figures/components.jpg?raw=true "Optional Title")


![](Figures/circuit_diagram.png?raw=true "Optional Title")
## Setup

### Ethereum

Install geth following link: https://geth.ethereum.org/install-and-build/Installing-Geth. In this project geth 1.8.27-stable is used.

Run geth with following command:<br/>`geth --testnet --syncmode "light" --rpc --rpcapi "eth,net,web3,personal" --rpccorsdomain '*' --rpcaddr 0.0.0.0 --rpcport 8545`<br/>
This command sync lightchain which is faster and uses less memory than real chain. However this is an experimental feature so if it does not work run the same command with `--syncmode "fast"`.

### node-red

Install node red following link: https://nodered.org/docs/getting-started/installation. In this project node-red v0.20.5 and node.js v8.16.0 is used. <br/>

### web3 node-red
In this project we used web3 v0.20.0, you can change the version but there's no guarantee that other versions work well with this project.<br/>
You can install web3 on node-red as follows:
go to `.node-red/` directory then under this directory you can install web3:<br/>
`npm install --save web3@0.20.0 --unsafe-perm=true --allow-root`<br/>
There is a configuration file named `settings.js` in the node-red directory. Open it with your favorite text editor and find setting `functionGlobalContext`. Then add `web3:require('web3')` under this setting. For example:<br/>
```
functionGlobalContext: {
//  osModule:require('os'),
    web3:require('web3')
}
```
Make sure that web3 is installed for node-red by looking at `package.json` file.

You can import the flow under `cloud/flows.json` to the node-red. Ethereum client must be already working before you deploy and use the flow. There is a static account address on the function `updateSensorData` if you want to use another account you need to change it.

### Smart Contract
You can deploy the smart contract or use already deployed one. The smart contract deployed on link https://ropsten.etherscan.io/address/0xcde24e25421174829a704e6411cc5ca1ce25756f.<br/>
In this project we used Brave+Metamask plugin which ease the signing new transactions and displaying account data. You can follow this link to install Brave + Metamask: https://brave.com/into-the-blockchain-brave-with-metamask/ <br/>
