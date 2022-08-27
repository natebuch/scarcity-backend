
;; mint-test-token
;; contract to mint a fungible test token for burning

;; constants
(impl-trait .citycoin-token-trait.citycoin-token)
(define-fungible-token test-token-two)

;;read only
(define-read-only (get-name)
  (ok "test-token-two")
)

(define-read-only (get-symbol)
  (ok "TTT")
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance test-token-two user))
)

;; public functions
(define-public (mint (amount uint) (recipient principal))
  (ft-mint? test-token-two amount recipient)
)

(define-public (burn (amount uint) (recipient principal))
  (ft-burn? test-token-two amount recipient)
)

;;These functions are for testing only and can be called directly.

