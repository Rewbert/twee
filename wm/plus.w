NAME diff
MODE completion
SORTS ANY
SIGNATURE
+: ANY ANY -> ANY
ORDERING
KBO
+=1
VARIABLES
X, Y, Z: ANY
EQUATIONS
+(X, Y) = +(Y, X)
+(X, +(Y, Z)) = +(+(X, Y), Z)
CONCLUSION
