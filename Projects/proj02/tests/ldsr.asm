.orig x0000
AND R3, R3, 0
ADD R3, R3, 2
ADD R4, R3, 3
LDSR R0, R3, R4
HALT

.fill x0750
MYLABEL .fill x6349
MYLABEL2 .fill x0A37

.end

;; R0 = x0A37, R3 = x0002, R4 = x0005
