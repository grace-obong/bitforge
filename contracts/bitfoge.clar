;; Title: BitForge Gaming Protocol
;;
;; Summary:
;; BitForge revolutionizes blockchain gaming by creating the first Bitcoin-native gaming infrastructure
;; that combines true asset ownership with cross-platform interoperability. Built on Stacks' Proof-of-Transfer
;; consensus, BitForge inherits Bitcoin's legendary security while delivering lightning-fast gaming experiences.
;;
;; Description:
;; BitForge Protocol transforms traditional gaming economics through Bitcoin-backed digital ownership.
;; Players forge unique gaming identities, collect interoperable assets across multiple game universes,
;; and participate in a merit-driven economy where skill and dedication translate to real Bitcoin rewards.

;; ERROR CONSTANTS & PROTOCOL DEFINITIONS

;; Core Protocol Errors
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))

;; Asset & Avatar Validation Errors
(define-constant ERR-INVALID-AVATAR (err u13))
(define-constant ERR-WORLD-NOT-FOUND (err u14))
(define-constant ERR-INVALID-NAME (err u15))
(define-constant ERR-INVALID-DESCRIPTION (err u16))
(define-constant ERR-INVALID-RARITY (err u17))
(define-constant ERR-INVALID-POWER-LEVEL (err u18))
(define-constant ERR-INVALID-ATTRIBUTES (err u19))
(define-constant ERR-INVALID-WORLD-ACCESS (err u20))
(define-constant ERR-INVALID-OWNER (err u21))

;; Experience & Progression Errors
(define-constant ERR-MAX-LEVEL-REACHED (err u22))
(define-constant ERR-MAX-EXPERIENCE-REACHED (err u23))
(define-constant ERR-INVALID-LEVEL-UP (err u24))

;; GAME MECHANICS & PROTOCOL CONFIGURATION

;; Core Game Balance Constants
(define-constant MAX-LEVEL u100)
(define-constant MAX-EXPERIENCE-PER-LEVEL u1000)
(define-constant BASE-EXPERIENCE-REQUIRED u100)

;; Protocol Configuration Variables
(define-data-var protocol-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-assets uint u0)
(define-data-var total-avatars uint u0)
(define-data-var total-worlds uint u0)

;; ACCESS CONTROL & SECURITY

;; Administrative Access Control
(define-map protocol-admin-whitelist
  principal
  bool
)

;; NFT TOKEN DEFINITIONS

;; Core Gaming NFTs
(define-non-fungible-token forge-asset uint)
(define-non-fungible-token forge-avatar uint)

;; DATA STRUCTURE DEFINITIONS

;; Forge Asset Metadata Structure
(define-map forge-asset-metadata
  { token-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint,
    world-id: uint,
    attributes: (list 10 (string-ascii 20)),
    experience: uint,
    level: uint,
  }
)

;; Avatar Identity & Progression Structure
(define-map avatar-metadata
  { avatar-id: uint }
  {
    name: (string-ascii 50),
    level: uint,
    experience: uint,
    achievements: (list 20 (string-ascii 50)),
    equipped-assets: (list 5 uint),
    world-access: (list 10 uint),
  }
)

;; Game World Configuration Structure
(define-map game-worlds
  { world-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    entry-requirement: uint,
    active-players: uint,
    total-rewards: uint,
  }
)

;; Competitive Leaderboard Structure
(define-map leaderboard
  { player: principal }
  {
    score: uint,
    games-played: uint,
    total-rewards: uint,
    avatar-id: uint,
    rank: uint,
    achievements: (list 20 (string-ascii 50)),
  }
)

;; INPUT VALIDATION FUNCTIONS

;; Validate asset and avatar naming conventions
(define-private (is-valid-name (name (string-ascii 50)))
  (and
    (>= (len name) u1)
    (<= (len name) u50)
    (not (is-eq name ""))
  )
)

;; Validate description length and content
(define-private (is-valid-description (description (string-ascii 200)))
  (and
    (>= (len description) u1)
    (<= (len description) u200)
    (not (is-eq description ""))
  )
)

;; Validate asset rarity categories
(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (or
    (is-eq rarity "common")
    (is-eq rarity "uncommon")
    (is-eq rarity "rare")
    (is-eq rarity "epic")
    (is-eq rarity "legendary")
  )
)

;; Validate power level within acceptable bounds
(define-private (is-valid-power-level (power uint))
  (and (>= power u1) (<= power u1000))
)

;; Validate asset attribute structure
(define-private (is-valid-attributes (attributes (list 10 (string-ascii 20))))
  (and
    (>= (len attributes) u1)
    (<= (len attributes) u10)
  )
)

;; Validate world access permissions
(define-private (is-valid-world-access (worlds (list 10 uint)))
  (and
    (>= (len worlds) u1)
    (<= (len worlds) u10)
    (fold check-world-exists worlds true)
  )
)

;; Helper function to verify world existence
(define-private (check-world-exists
    (world-id uint)
    (valid bool)
  )
  (and valid (is-some (get-world-details world-id)))
)

;; ACCESS CONTROL & UTILITY FUNCTIONS

;; Check administrative privileges
(define-read-only (is-protocol-admin (sender principal))
  (default-to false (map-get? protocol-admin-whitelist sender))
)

;; Validate principal addresses
(define-read-only (is-valid-principal (input principal))
  (and
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

;; Enhanced principal security validation
(define-read-only (is-safe-principal (input principal))
  (and
    (is-valid-principal input)
    (or
      (is-protocol-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

;; DATA RETRIEVAL FUNCTIONS

;; Retrieve world configuration details
(define-read-only (get-world-details (world-id uint))
  (map-get? game-worlds { world-id: world-id })
)

;; Retrieve avatar metadata and progression
(define-read-only (get-avatar-details (avatar-id uint))
  (map-get? avatar-metadata { avatar-id: avatar-id })
)

;; Get top performing players (simplified implementation)
(define-read-only (get-top-players)
  (let ((max-entries (var-get max-leaderboard-entries)))
    (list
      tx-sender
    )
  )
)

;; EXPERIENCE SYSTEM FUNCTIONS

;; Calculate experience required for next level
(define-read-only (get-next-level-requirement (avatar-id uint))
  (match (get-avatar-details avatar-id)
    metadata (ok (calculate-level-up-experience (get level metadata)))
    ERR-INVALID-AVATAR
  )
)

;; Validate experience gain eligibility
(define-read-only (can-receive-experience
    (avatar-id uint)
    (experience-amount uint)
  )
  (match (get-avatar-details avatar-id)
    metadata (ok (and
      (< (get level metadata) MAX-LEVEL)
      (validate-experience-gain (get experience metadata) experience-amount
        (get level metadata)
      )
    ))
    ERR-INVALID-AVATAR
  )
)

;; PROTOCOL ADMINISTRATION FUNCTIONS

;; Initialize protocol with core parameters
(define-public (initialize-protocol
    (entry-fee uint)
    (max-entries uint)
  )
  (begin
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= entry-fee u1) (<= entry-fee u1000)) ERR-INVALID-FEE)
    (asserts! (and (>= max-entries u1) (<= max-entries u500)) ERR-INVALID-ENTRIES)

    (var-set protocol-fee entry-fee)
    (var-set max-leaderboard-entries max-entries)

    (ok true)
  )
)

;; ASSET MANAGEMENT FUNCTIONS

;; Mint new forge assets with comprehensive metadata
(define-public (mint-forge-asset
    (name (string-ascii 50))
    (description (string-ascii 200))
    (rarity (string-ascii 20))
    (power-level uint)
    (world-id uint)
    (attributes (list 10 (string-ascii 20)))
  )
  (let ((token-id (+ (var-get total-assets) u1)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
    (asserts! (is-valid-rarity rarity) ERR-INVALID-RARITY)
    (asserts! (is-valid-power-level power-level) ERR-INVALID-POWER-LEVEL)
    (asserts! (is-some (get-world-details world-id)) ERR-WORLD-NOT-FOUND)
    (asserts! (is-valid-attributes attributes) ERR-INVALID-ATTRIBUTES)

    (try! (nft-mint? forge-asset token-id tx-sender))