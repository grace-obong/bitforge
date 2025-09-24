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

    (map-set forge-asset-metadata { token-id: token-id } {
      name: name,
      description: description,
      rarity: rarity,
      power-level: power-level,
      world-id: world-id,
      attributes: attributes,
      experience: u0,
      level: u1,
    })

    (var-set total-assets token-id)
    (ok token-id)
  )
)

;; Transfer forge assets between players
(define-public (transfer-game-asset
    (token-id uint)
    (recipient principal)
  )
  (begin
    (asserts!
      (is-eq tx-sender
        (unwrap! (nft-get-owner? forge-asset token-id) ERR-INVALID-GAME-ASSET)
      )
      ERR-NOT-AUTHORIZED
    )

    (asserts! (is-valid-principal recipient) ERR-INVALID-INPUT)

    (nft-transfer? forge-asset token-id tx-sender recipient)
  )
)

;; AVATAR SYSTEM FUNCTIONS

;; Create new gaming avatar with world access
(define-public (create-avatar
    (name (string-ascii 50))
    (world-access (list 10 uint))
  )
  (let ((avatar-id (+ (var-get total-avatars) u1)))
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-world-access world-access) ERR-INVALID-WORLD-ACCESS)
    (asserts! (is-none (map-get? leaderboard { player: tx-sender }))
      ERR-ALREADY-REGISTERED
    )

    (try! (nft-mint? forge-avatar avatar-id tx-sender))

    (map-set avatar-metadata { avatar-id: avatar-id } {
      name: name,
      level: u1,
      experience: u0,
      achievements: (list),
      equipped-assets: (list),
      world-access: world-access,
    })

    (map-set leaderboard { player: tx-sender } {
      score: u0,
      games-played: u0,
      total-rewards: u0,
      avatar-id: avatar-id,
      rank: u0,
      achievements: (list),
    })

    (var-set total-avatars avatar-id)
    (ok avatar-id)
  )
)

;; Update avatar experience with automatic leveling
(define-public (update-avatar-experience
    (avatar-id uint)
    (experience-gained uint)
  )
  (let (
      (current-metadata (unwrap! (get-avatar-details avatar-id) ERR-INVALID-AVATAR))
      (avatar-owner (unwrap! (nft-get-owner? forge-avatar avatar-id) ERR-INVALID-AVATAR))
      (current-level (get level current-metadata))
      (current-experience (get experience current-metadata))
    )
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= avatar-id (var-get total-avatars)) ERR-INVALID-AVATAR)
    (asserts! (> experience-gained u0) ERR-INVALID-INPUT)
    (asserts! (< current-level MAX-LEVEL) ERR-MAX-LEVEL-REACHED)
    (asserts!
      (validate-experience-gain current-experience experience-gained
        current-level
      )
      ERR-MAX-EXPERIENCE-REACHED
    )

    (let (
        (new-experience (+ current-experience experience-gained))
        (should-level-up (can-level-up current-experience experience-gained current-level))
        (new-level (if should-level-up
          (+ current-level u1)
          current-level
        ))
      )
      (asserts! (or (not should-level-up) (<= new-level MAX-LEVEL))
        ERR-MAX-LEVEL-REACHED
      )

      (map-set avatar-metadata { avatar-id: avatar-id }
        (merge current-metadata {
          experience: new-experience,
          level: new-level,
        })
      )

      (ok should-level-up)
    )
  )
)

;; WORLD MANAGEMENT FUNCTIONS

;; Create new game worlds with entry requirements
(define-public (create-game-world
    (name (string-ascii 50))
    (description (string-ascii 200))
    (entry-requirement uint)
  )
  (let ((world-id (+ (var-get total-worlds) u1)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
    (asserts! (>= entry-requirement u0) ERR-INVALID-INPUT)

    (map-set game-worlds { world-id: world-id } {
      name: name,
      description: description,
      entry-requirement: entry-requirement,
      active-players: u0,
      total-rewards: u0,
    })

    (var-set total-worlds world-id)
    (ok world-id)
  )
)

;; COMPETITIVE LEADERBOARD FUNCTIONS

;; Update player competitive scores
(define-public (update-player-score
    (player principal)
    (new-score uint)
  )
  (let ((current-stats (unwrap! (map-get? leaderboard { player: player }) ERR-PLAYER-NOT-FOUND)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-principal player) ERR-INVALID-INPUT)
    (asserts! (and (>= new-score u0) (<= new-score u10000)) ERR-INVALID-SCORE)

    (map-set leaderboard { player: player }
      (merge current-stats {
        score: new-score,
        games-played: (+ (get games-played current-stats) u1),
      })
    )

    (ok true)
  )
)

;; BITCOIN REWARD DISTRIBUTION FUNCTIONS

;; Distribute Bitcoin rewards to top performers
(define-public (distribute-bitcoin-rewards)
  (let ((top-players (get-top-players)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)

    (try! (fold distribute-reward (filter is-valid-reward-candidate top-players)
      (ok true)
    ))

    (ok true)
  )
)

;; Validate reward eligibility
(define-private (is-valid-reward-candidate (player principal))
  (match (map-get? leaderboard { player: player })
    stats (and
      (> (get score stats) u0)
      (is-valid-principal player)
    )
    false
  )
)

;; Process individual reward distribution
(define-private (distribute-reward
    (player principal)
    (previous-result (response bool uint))
  )
  (match (map-get? leaderboard { player: player })
    player-stats (let ((reward-amount (calculate-reward (get score player-stats))))
      (if (and (is-ok previous-result) (> reward-amount u0))
        (begin
          (map-set leaderboard { player: player }
            (merge player-stats { total-rewards: (+ (get total-rewards player-stats) reward-amount) })
          )
          (ok true)
        )
        previous-result
      )
    )
    previous-result
  )
)

;; MATHEMATICAL & GAME BALANCE FUNCTIONS

;; Calculate merit-based rewards
(define-private (calculate-reward (score uint))
  (if (and (> score u100) (<= score u10000))
    (* score u10)
    u0
  )
)

;; Calculate progressive experience requirements
(define-private (calculate-level-up-experience (current-level uint))
  (* BASE-EXPERIENCE-REQUIRED current-level)
)

;; Validate experience gain to prevent exploitation
(define-private (validate-experience-gain
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (max-allowed-gain (calculate-level-up-experience current-level))
      (new-total-experience (+ current-experience gained-experience))
    )
    (and
      (<= gained-experience max-allowed-gain)
      (<= new-total-experience (* MAX-EXPERIENCE-PER-LEVEL current-level))
    )
  )
)

;; Determine automatic level progression eligibility
(define-private (can-level-up
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (new-total-experience (+ current-experience gained-experience))
      (required-experience (calculate-level-up-experience current-level))
    )
    (>= new-total-experience required-experience)
  )
)

;; PROTOCOL INITIALIZATION

;; Initialize protocol with deployer as admin
(map-set protocol-admin-whitelist tx-sender true)
