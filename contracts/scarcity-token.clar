;; scarcity-token
;; Mints NFT by burning specified number of fungible tokens

;;traits
(use-trait citycoin-token .citycoin-token-trait.citycoin-token)

;; errors
(define-constant err-owner-only (err u1000))
(define-constant err-not-enough-burn-tokens (err u1001))
(define-constant err-not-token-owner (err u1002))

;; constants
(define-constant contract-owner tx-sender)
(define-constant min-burn u10)

;; tokens
(define-non-fungible-token scarcity-token uint)

;; data maps and vars
(define-data-var last-token-id uint u0)

;; public functions
;; (define-public (mint-nft-test (burn-amount uint) (recipient principal))
;;   (let
;;     (
;;       (token-id (+ (var-get last-token-id) u1))
;;     )
;;     (asserts! (>= burn-amount min-burn) err-not-enough-burn-tokens)
;;     (var-set last-token-id token-id)
;;     (try! (nft-mint? scarcity-token token-id tx-sender))
;;     (contract-call? .mint-test-token burn-ft-test-token 
;;     burn-amount tx-sender)  
;;   )  
;; )

(define-public (mint (burn-amount uint) (recipient principal) (citycoin-contract <citycoin-token>))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (>= burn-amount min-burn) err-not-enough-burn-tokens)
    (var-set last-token-id token-id)
    (try! (nft-mint? scarcity-token token-id tx-sender))
    (contract-call? citycoin-contract burn burn-amount tx-sender)
  )  
)

(define-public (burn (id uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) err-not-token-owner)
    (nft-burn? scarcity-token id owner)
  )
)

;; private functions
(define-private (check-contract)
  (ok (asserts! (is-eq tx-sender contract-owner) err-owner-only))
)





;; (define-public (burn-to-mint (sender principal) (amount uint) (token TokenName))
;;   (begin
;;     (try! (burn-ft token amount sender))
;;     (try! (mint sender))
;;   )
;; )

;; (define-private (burn-ft (amount uint) (sender principal))
;;   (begin
;;     (asserts! (>= amount min-burn) err-not-enough-burn-tokens)
;;     (try! (ft-burn? test-token amount sender))
;;   )
;; )

;; (define-private (mint (recipient principal))
;;   (let
;;     (
;;       (token-id (+ (var-get last-token-id) u1))
;;     )
;;     (try! (nft-mint? scarcity-token token-id recipient))
;;     (var-set last-token-id token-id)
;;     (ok token-id)
;;   )  
;; )
