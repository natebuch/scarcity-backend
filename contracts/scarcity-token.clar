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
(define-constant err-whitelist-list-full (err u1005))

;; constants
(define-constant contract-owner tx-sender)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; maps
(define-map whitelisted-assets principal bool)

;; data maps and vars
(define-data-var min-burn-amount uint u1000000)
(define-data-var last-token-id uint u1)
(define-data-var whitelist (list 10 principal) (list))

(define-map User-info principal {burnt-amount: uint, current-nft-id: (optional uint)})

;; read-only functions

(define-read-only (is-whitelisted (asset-contract principal))
  (default-to false (map-get? whitelisted-assets asset-contract)) 
)
 
(define-read-only (get-whitelist)
  (ok (var-get whitelist))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? scarcity-token token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-user-info)
  (ok (map-get? User-info tx-sender))
)

(define-read-only (get-min-burn-amount)
  (ok (var-get min-burn-amount))
)

;; public functions
(define-public (set-whitelisted (asset-contract principal) (whitelisted bool))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (map-set whitelisted-assets asset-contract whitelisted)
    (ok 
      (var-set whitelist 
        (unwrap! 
          (as-max-len? (append (var-get whitelist) asset-contract) u10) 
        err-whitelist-list-full)
      )
    )
  )
)

(define-public (set-burn-amount (amount uint))
  (begin
    (asserts! (is-eq contract-caller contract-owner) err-unauthorized)
    (ok (var-set min-burn-amount amount))
  )
)

(define-public (mint-scarcity (burn-amount uint) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (user-info (map-get? User-info tx-sender))
    )
    (asserts! (is-whitelisted (contract-of citycoin-contract)) err-asset-not-whitelisted)  
    (asserts! (>= burn-amount (var-get min-burn-amount)) err-not-enough-burn-tokens)
    (var-set last-token-id token-id)
    (match user-info response
      (match (get current-nft-id response) response2
        (begin 
          (try! (burn-on-mint response2 tx-sender))
          (map-set User-info tx-sender {burnt-amount: (+ burn-amount (get burnt-amount response)), current-nft-id: (some token-id)})
        )
        (map-set User-info tx-sender {burnt-amount: (+ burn-amount (get burnt-amount response)), current-nft-id: (some token-id)})
      )
      (map-insert User-info tx-sender {burnt-amount: burn-amount, current-nft-id: (some token-id)})
    )
    (try! (nft-mint? scarcity-token token-id tx-sender))
    (contract-call? citycoin-contract burn burn-amount tx-sender)
  )  
)

;; Burns NFT and previous burn amounts
(define-public (burn-scarcity-data (id uint))
  (begin 
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (map-delete User-info tx-sender)
    (nft-burn? scarcity-token id tx-sender)
  )
)

;; Burns NFT only but keeps previous burn amounts
(define-public (burn-scarcity-nft (id uint))
  (let 
    ( 
      (amount (unwrap-panic (get burnt-amount (map-get? User-info tx-sender))))
    )
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (map-set User-info tx-sender {burnt-amount: amount, current-nft-id: none})
    (nft-burn? scarcity-token id tx-sender)
  )
)

;;private functions
(define-private (burn-on-mint (id uint) (owner principal)) 
  (begin 
    (asserts! (is-eq owner (unwrap! (nft-get-owner? scarcity-token id) err-token-not-found)) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)

