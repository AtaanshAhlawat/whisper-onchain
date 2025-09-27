# 🗣️ Whisper OnChain

<h4 align="center">
  A decentralized anonymous feedback board built on Ethereum
</h4>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#tech-stack">Tech Stack</a>
</p>

Whisper OnChain is a decentralized application that allows users to submit honest, anonymous feedback directly on the blockchain. Built for ETHGlobal New Delhi, this platform ensures complete anonymity while maintaining the integrity of feedback through blockchain technology.

## ✨ Features

- 🕵️‍♂️ **Truly Anonymous**: Submit feedback without revealing your identity
- 📝 **Categorized Feedback**: Organize feedback into Positive, Constructive, and Ideas
- 🔗 **Fully On-Chain**: All feedback is stored securely on the Ethereum blockchain
- 🚀 **Quick Submission**: Simple and intuitive interface for submitting feedback
- 🔍 **Transparent**: Verify all feedback on the blockchain

## 🚀 Getting Started

### Prerequisites

- Node.js (v18 or later)
- Yarn (v1.22+)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/whisper-onchain.git
   cd whisper-onchain
   ```

2. Install dependencies:
   ```bash
   yarn install
   ```

### Running Locally

1. Start the local blockchain:
   ```bash
   cd packages/hardhat
   yarn chain
   ```

2. In a new terminal, deploy the contract:
   ```bash
   cd packages/hardhat
   yarn deploy
   ```

3. Start the frontend:
   ```bash
   cd packages/nextjs
   yarn start
   ```

4. Open [http://localhost:3000](http://localhost:3000) in your browser to view the app.

## 🛠 Tech Stack

- **Frontend**: Next.js, React, TypeScript, Tailwind CSS
- **Blockchain**: Solidity, Hardhat, Ethers.js
- **Wallet Integration**: RainbowKit, Wagmi
- **Development**: TypeScript, Yarn Workspaces

## 📝 How It Works

1. Connect your wallet (no personal data is stored)
2. Select a feedback category
3. Type your feedback
4. Submit to the blockchain
5. View all anonymous feedback from the community

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
