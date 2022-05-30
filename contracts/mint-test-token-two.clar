
;; mint-test-token
;; contract to mint a fungible test token for burning

;; constants
(impl-trait .citycoin-token-trait.citycoin-token)
(define-fungible-token test-token-two)

;; data maps and vars

;; private functions
;;

;; public functions
(define-public (mint (amount uint) (recipient principal))
  (ft-mint? test-token-two amount recipient)
)

(define-public (burn (amount uint) (recipient principal))
  (ft-burn? test-token-two amount recipient)
)
