# FundMe Smart Contract

This project contains a simple crowdfunding smart contract written in Solidity. The contract allows users to fund it with ETH, requiring a minimum USD value per contribution (using Chainlink price feeds). The contract owner can withdraw all funds.

## 📍 Deployment

- **Network:** Ethereum Sepolia Testnet
- **Contract Address:** [`0x52BcF2ad3E0589C784c2843232Cf91720Bb1756D`](https://sepolia.etherscan.io/address/0x52BcF2ad3E0589C784c2843232Cf91720Bb1756D)

## 📦 Features

- Accepts ETH funding with a **minimum contribution of $5** (converted via Chainlink price feed).
- Stores contributors’ addresses and amounts.
- Allows only the contract **owner** to withdraw all funds.
- Uses a **modular** price conversion library (`PriceConverter`).

## 🔧 Technologies

- Solidity `^0.8.24`
- Chainlink AggregatorV3Interface
- Chainlink ETH/USD Price Feed (Sepolia): `0x694AA1769357215DE4FAC081bf1f309aDC325306`

## 🧠 How It Works

This section describes the purpose and behavior of each function and modifier in the smart contract and its associated library.

---

### ### 🧾 FundMe.sol

#### `constructor()`
- **Description:** Initializes the contract and sets the `owner` to the address that deployed the contract.
- **Visibility:** Public (implicitly)
- **Runs:** Once during contract deployment

---

#### `fund()`
- **Description:** Allows any user to send ETH to the contract if the amount is worth at least $5 (USD) based on real-time conversion using Chainlink's price feed.
- **Checks:**
  - Uses the `PriceConverter` library to convert the sent ETH to USD.
  - Requires that the value sent is greater than or equal to `minimumUsd`.
- **Effects:**
  - Stores the funder's address in the `funders` array.
  - Updates their total contribution in the `addressToAmountFunded` mapping.

---

#### `withdraw()`
- **Description:** Allows only the contract owner to withdraw all funds from the contract.
- **Steps:**
  - Iterates through all previous funders and resets their contributed amount to zero.
  - Resets the `funders` array to an empty state.
  - Sends the entire contract balance to the owner's address using `.call{value: ...}`.
 
---

#### `receive()`
- **Description:** Handle tx that send some value to the contract without calling any function.

---

#### `fallback()`
- **Description:** Handle tx that send some value to the contract using some calldata that doesn't exists on this contract.

---

#### `onlyOwner` (modifier)
- **Description:** Ensures that only the `owner` of the contract can execute the function it modifies.
- **Reverts:** If `msg.sender` is not equal to the `owner`.

---

### 🧮 PriceConverter.sol (Library)

#### `getPrice()`
- **Description:** Fetches the latest ETH/USD price from Chainlink’s decentralized oracle.
- **Returns:** Price of 1 ETH in USD with 18 decimals (by multiplying Chainlink's 8-decimal price by `1e10`).

---

#### `getConversionRate(uint256 ethAmount)`
- **Description:** Converts a given ETH amount (in wei) into its equivalent USD value using the Chainlink price feed.
- **Formula:** `ethAmountInUsd = (ethPrice * ethAmount) / 1e18`

This handles fixed-point arithmetic correctly in Solidity.
- **Returns:** The USD value of the input ETH amount (18 decimals).

---

## 📌 Summary Table

| Function / Modifier       | Purpose                                                                 |
|---------------------------|-------------------------------------------------------------------------|
| `constructor()`           | Sets the deployer as contract owner                                     |
| `fund()`                  | Allows users to send ETH if worth ≥ $5                                 |
| `withdraw()`              | Lets the owner withdraw all ETH and reset contributions                 |
| `onlyOwner`               | Restricts access to owner-only features                                 |
| `getPrice()`              | Returns the current ETH/USD rate (Chainlink feed)                       |
| `getConversionRate()`     | Converts a given ETH amount to USD based on real-time exchange rate     |
