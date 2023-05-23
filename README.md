# Contract

The initial supply of tokens is 21 billion tokens. 50% of this is given to the contract owner, while the remaining 50% is kept in the contract for sale.

There is a transaction tax of 2.1% until the total supply of tokens is less than 2.1 billion. This tax is burned by sending it to the 0x000000000000000000000000000000000000dEaD address.

During token sale, each unique address can purchase a maximum of 100 million tokens for a price of 0.000000001 ETH per token. If an address sends more Ether than required for this maximum limit, transaction will fail.

The token sale continues until all the tokens kept for sale in the contract are sold. When this happens, the contract will not accept further Ether.

Each token transfer has a maximum limit of 100 million tokens until the total number of token holders reaches 300. After this point, this transfer limit is lifted.

Contract owner is exempted from transaction tax and the maximum transfer limit. This is for setting up liquidity of dex. Then contract will be renounced.

The contract provides functions to check the number of tokens purchased by a specific address and the remaining tokens available for sale.
