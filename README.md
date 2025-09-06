# BitForge Gaming Protocol

[![Clarity](https://img.shields.io/badge/Clarity-v3-blue)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-2.x-orange)](https://stacks.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](https://github.com/grace-obong/bitforge)

> The first Bitcoin-native gaming infrastructure that combines true asset ownership with cross-platform interoperability.

## 🎮 Overview

BitForge revolutionizes blockchain gaming by creating a comprehensive gaming protocol built on Stacks' Proof-of-Transfer consensus mechanism. The protocol inherits Bitcoin's legendary security while delivering lightning-fast gaming experiences through true digital asset ownership and merit-driven economics.

### Key Features

- **🔐 Bitcoin-Native Security**: Built on Stacks PoX consensus for maximum security
- **🎯 True Asset Ownership**: NFT-based gaming assets with full player control  
- **🌍 Cross-Platform Interoperability**: Assets work across multiple game universes
- **⚡ Merit-Driven Economy**: Skill and dedication translate to real Bitcoin rewards
- **🏆 Competitive Leaderboards**: Fair ranking system with automated reward distribution
- **👤 Avatar Progression**: Level-based character advancement with experience systems
- **🎨 Customizable Game Worlds**: Create and manage gaming environments

## 🏗️ Architecture

The BitForge protocol is implemented as a single Clarity smart contract with the following core components:

```
BitForge Protocol
├── Asset Management (NFTs)
│   ├── Forge Assets (Gaming Items)
│   └── Forge Avatars (Player Identities)
├── Experience System
│   ├── Level Progression (1-100)
│   └── Merit-Based Rewards
├── World Management
│   ├── Game World Creation
│   └── Access Control
├── Competitive System
│   ├── Leaderboards
│   └── Bitcoin Rewards
└── Admin Controls
    ├── Protocol Configuration
    └── Access Management
```

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Stacks CLI](https://docs.stacks.co/stacks-cli/installation) (optional)

## 🚀 Quick Start

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/grace-obong/bitforge.git
   cd bitforge
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Local Development

1. **Start Clarinet console**

   ```bash
   clarinet console
   ```

2. **Deploy contract locally**

   ```clarity
   ::deploy_contracts
   ```

3. **Interact with the protocol**

   ```clarity
   (contract-call? .bitfoge initialize-protocol u50 u100)
   ```

## 🔧 Contract API Reference

### Core Functions

#### Administrative Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `initialize-protocol` | Initialize protocol with core parameters | `entry-fee: uint, max-entries: uint` |

#### Asset Management

| Function | Description | Parameters |
|----------|-------------|------------|
| `mint-forge-asset` | Create new gaming asset NFT | `name, description, rarity, power-level, world-id, attributes` |
| `transfer-game-asset` | Transfer asset between players | `token-id: uint, recipient: principal` |

#### Avatar System

| Function | Description | Parameters |
|----------|-------------|------------|
| `create-avatar` | Create new gaming avatar | `name: string-ascii 50, world-access: list 10 uint` |
| `update-avatar-experience` | Update avatar XP and level | `avatar-id: uint, experience-gained: uint` |

#### World Management

| Function | Description | Parameters |
|----------|-------------|------------|
| `create-game-world` | Create new game environment | `name, description, entry-requirement` |

#### Competitive System

| Function | Description | Parameters |
|----------|-------------|------------|
| `update-player-score` | Update leaderboard scores | `player: principal, new-score: uint` |
| `distribute-bitcoin-rewards` | Distribute rewards to top players | None |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-avatar-details` | Retrieve avatar metadata | Avatar details or none |
| `get-world-details` | Get world configuration | World details or none |
| `get-top-players` | Get leaderboard leaders | List of top players |
| `get-next-level-requirement` | Calculate XP needed for next level | XP requirement |

### Data Structures

#### Forge Asset Metadata

```clarity
{
  name: (string-ascii 50),
  description: (string-ascii 200),
  rarity: (string-ascii 20),        ; "common", "uncommon", "rare", "epic", "legendary"
  power-level: uint,                ; 1-1000
  world-id: uint,
  attributes: (list 10 (string-ascii 20)),
  experience: uint,
  level: uint
}
```

#### Avatar Metadata

```clarity
{
  name: (string-ascii 50),
  level: uint,                      ; 1-100
  experience: uint,
  achievements: (list 20 (string-ascii 50)),
  equipped-assets: (list 5 uint),
  world-access: (list 10 uint)
}
```

## 🎯 Game Mechanics

### Experience System

- **Level Range**: 1-100
- **Base XP Requirement**: 100 XP per level
- **Progressive Scaling**: XP requirements increase with level
- **Maximum XP Per Level**: 1,000 XP

### Asset Rarity System

| Rarity | Power Range | Drop Rate |
|--------|-------------|-----------|
| Common | 1-200 | High |
| Uncommon | 201-400 | Medium |
| Rare | 401-600 | Low |
| Epic | 601-800 | Very Low |
| Legendary | 801-1000 | Ultra Rare |

### Reward Distribution

```clarity
reward = score * 10 (for scores 100-10,000)
```

## 🧪 Testing

The project includes comprehensive test coverage using Vitest and Clarinet SDK.

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```
tests/
└── bitfoge.test.ts          # Main contract tests
```

## 🔐 Security Features

### Access Control

- **Admin Whitelist**: Protocol-level administrative controls
- **Principal Validation**: Enhanced security for user interactions
- **Safe Transfer Mechanisms**: Secure NFT transfer protocols

### Input Validation

- **Name Validation**: Ensures proper naming conventions (1-50 characters)
- **Description Limits**: Prevents spam with 1-200 character limits
- **Rarity Enforcement**: Strict rarity category validation
- **Power Level Bounds**: Maintains game balance (1-1000 range)

### Anti-Exploitation Measures

- **Experience Validation**: Prevents XP farming exploits
- **Level Cap Enforcement**: Maximum level 100 with overflow protection
- **Score Bounds**: Leaderboard scores capped at 10,000

## 📊 Protocol Statistics

The protocol tracks key metrics:

- `total-assets`: Number of minted gaming assets
- `total-avatars`: Number of created avatars  
- `total-worlds`: Number of game worlds
- `total-prize-pool`: Accumulated Bitcoin rewards
- `protocol-fee`: Current transaction fees

## 🌐 Deployment

### Testnet Deployment

1. **Configure Clarinet.toml**

   ```toml
   [network]
   name = "testnet"
   node_rpc_address = "https://api.testnet.hiro.so"
   ```

2. **Deploy to testnet**

   ```bash
   clarinet publish --testnet
   ```

### Mainnet Deployment

1. **Update network configuration**

   ```toml
   [network]
   name = "mainnet"
   node_rpc_address = "https://api.hiro.so"
   ```

2. **Deploy to mainnet**

   ```bash
   clarinet publish --mainnet
   ```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Run the test suite (`npm test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📝 Error Codes

| Error Code | Constant | Description |
|------------|----------|-------------|
| u1 | ERR-NOT-AUTHORIZED | Insufficient permissions |
| u2 | ERR-INVALID-GAME-ASSET | Asset validation failed |
| u3 | ERR-INSUFFICIENT-FUNDS | Not enough funds |
| u4 | ERR-TRANSFER-FAILED | Asset transfer error |
| u5 | ERR-LEADERBOARD-FULL | Maximum entries reached |
| u6 | ERR-ALREADY-REGISTERED | Player already exists |
| u13 | ERR-INVALID-AVATAR | Avatar validation failed |
| u22 | ERR-MAX-LEVEL-REACHED | Level 100 cap reached |

## 📚 Documentation

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://book.clarity-lang.org/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)

## 🔗 Links

- **Website**: [BitForge Protocol](https://bitforge.game)
- **Discord**: [Join Community](https://discord.gg/bitforge)
- **Twitter**: [@BitForgeProtocol](https://twitter.com/bitforgeprotocol)
- **Medium**: [BitForge Blog](https://medium.com/@bitforge)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Stacks](https://stacks.org/) blockchain
- Powered by [Clarity](https://clarity-lang.org/) smart contract language
- Testing framework by [Hiro](https://hiro.so/)

---

**Built with ❤️ by the BitForge Team**

*Forging the future of blockchain gaming on Bitcoin.*
