;; scarcity-token
;; Mints NFT by burning specified number of fungible tokens

;;traits
(use-trait citycoin-token .citycoin-token-trait.citycoin-token)

;; errors
(define-constant err-owner-only (err u1000))
(define-constant err-not-enough-burn-tokens (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-token-not-found (err u1003))

;; constants
(define-constant contract-owner tx-sender)
(define-constant min-burn u10)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; data maps and vars
(define-data-var last-token-id uint u0)

;; public functions
(define-public (mint (burn-amount uint) (recipient principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (>= burn-amount min-burn) err-not-enough-burn-tokens)
    (var-set last-token-id token-id)
    (contract-call? citycoin-contract burn burn-amount tx-sender)
    (try! (nft-mint? scarcity-token token-id tx-sender))
  )  
)

(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (is-eq owner (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)