# secure-transfer-protocol
Double confirm secure transfer protocol on Ethereum

# Usage
When transferring large amounts of cryptos, inputting the wrong address can cause irreparable loss. Instead of sending directly to the receiver's address, the funds can be sent to this smart contract with the receiver's address specified. The sender can then notify the receiver via other channels (emails, WhatsApp, etc). The receiver confirms and withdraws the funds. In case the address is incorrect or the receiver loses access to the address, the sender can be refunded. 

Additionally, if both the sender and receiver addresses are controlled by the same person or trusted persons, this smart contract can act as a recoverable wallet. If the person loses one key, he/she can always recover the funds using another key.

The idea is inspired by the money transfer in TradFi (Interac, Wire Transfer, SWIFT etc). Many other well-developed mechanisms in TradFi should be highlighted in the Crypto world. 

# Dev
* ERC20 implementation
* Frontend dev