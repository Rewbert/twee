-- | Equations.
{-# LANGUAGE TypeFamilies #-}
module Twee.Equation where

import Twee.Base
import Control.Monad

--------------------------------------------------------------------------------
-- * Equations.
--------------------------------------------------------------------------------

data Equation f =
  (:=:) {
    eqn_lhs :: {-# UNPACK #-} !(Term f),
    eqn_rhs :: {-# UNPACK #-} !(Term f) }
  deriving (Eq, Ord, Show)
type EquationOf a = Equation (ConstantOf a)

instance Symbolic (Equation f) where
  type ConstantOf (Equation f) = f
  termsDL (t :=: u) = termsDL t `mplus` termsDL u
  subst_ sub (t :=: u) = subst_ sub t :=: subst_ sub u

instance PrettyTerm f => Pretty (Equation f) where
  pPrint (x :=: y) = pPrint x <+> text "=" <+> pPrint y

-- | Order an equation roughly left-to-right.
-- However, there is no guarantee that the result is oriented.
order :: Function f => Equation f -> Equation f
order (l :=: r)
  | l == r = l :=: r
  | lessEqSkolem l r = r :=: l
  | otherwise = l :=: r

-- | Apply a function to both sides of an equation.
bothSides :: (Term f -> Term f') -> Equation f -> Equation f'
bothSides f (t :=: u) = f t :=: f u

-- | Is an equation of the form t = t?
trivial :: Eq f => Equation f -> Bool
trivial (t :=: u) = t == u

simplerThan :: Function f => Equation f -> Equation f -> Bool
eq1 `simplerThan` eq2 =
  --traceShow (hang (pPrint eq1) 2 (text "`simplerThan`" <+> pPrint eq2 <+> text "=" <+> pPrint res)) res
  t1 `lessEqSkolem` t2 && (t1 /= t2 || ((u1 `lessEqSkolem` u2 && u1 /= u2)))
  where
    t1 :=: u1 = canonicalise (order eq1)
    t2 :=: u2 = canonicalise (order eq2)
