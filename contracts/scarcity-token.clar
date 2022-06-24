;; scarcity-token
;; Mints NFT by burning specified number of fungible tokens

;;traits
(use-trait citycoin-token .citycoin-token-trait.citycoin-token)

;; errors
(define-constant err-unauthorized (err u1000))
(define-constant err-not-enough-burn-tokens (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-token-not-found (err u1003))
(define-constant err-asset-not-whitelisted (err u1004))

;; constants
(define-constant contract-owner tx-sender)
(define-constant min-burn u10)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; maps
(define-map whitelisted-assets principal bool)

;; data maps and vars
(define-data-var last-token-id uint u0)

;; read-only functions
(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? whitelisted-assets asset-contract))
)

;; public functions
(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner ) err-unauthorized)
    (ok (map-set whitelisted-assets asset-contract whitelisted))
  )
)

(define-public (mint (burn-amount uint) (recipient principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-whitelisted (contract-of citycoin-contract)) err-asset-not-whitelisted)  
    (asserts! (>= burn-amount min-burn) err-not-enough-burn-tokens)
    (var-set last-token-id token-id)
    (try! (nft-mint? scarcity-token token-id tx-sender))
    (contract-call? citycoin-contract burn burn-amount tx-sender)
  )  
)

(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (is-eq owner (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)