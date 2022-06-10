
;; mint-test-token
;; contract to mint a fungible test token for burning

;; constants
(impl-trait .citycoin-token-trait.citycoin-token)
(define-fungible-token test-token-one)

;; public functions
(define-public (mint (amount uint) (recipient principal))
  (ft-mint? test-token-one amount recipient)
)

(define-public (burn (amount uint) (recipient principal))
  (ft-burn? test-token-one amount recipient)
)

;;These functions are for testing only and can be called directly.
