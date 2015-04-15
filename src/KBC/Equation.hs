{-# LANGUAGE TypeFamilies #-}
module KBC.Equation where

import KBC.Base
import KBC.Constraints
import KBC.Term
import KBC.Utils
import Control.Monad
import Data.Rewriting.Rule hiding (isVariantOf, vars)
import Data.List

data Equation f v = Tm f v :==: Tm f v deriving (Eq, Ord, Show)
type EquationOf a = Equation (ConstantOf a) (VariableOf a)

instance Symbolic (Equation f v) where
  type ConstantOf (Equation f v) = f
  type VariableOf (Equation f v) = v
  termsDL (t :==: u) = termsDL t `mplus` termsDL u
  substf sub (t :==: u) = substf sub t :==: substf sub u

instance (PrettyTerm f, Pretty v) => Pretty (Equation f v) where
  pPrint (x :==: y) = hang (pPrint x <+> text "=") 2 (pPrint y)

order :: (Sized f, Ord f, Ord v) => Equation f v -> Equation f v
order (l :==: r)
  | measure l >= measure r = l :==: r
  | otherwise = r :==: l

unorient :: Rule f v -> Equation f v
unorient (Rule l r) = l :==: r

orient :: (Minimal f, Sized f, Ord f, Ord v, Numbered v) => Equation f v -> [Constrained (Rule f v)]
orient (l :==: r) =
  case orientTerms l r of
    Just GT -> [Constrained (toContext FTrue) (Rule l r)]
    Just LT -> [Constrained (toContext FTrue) (Rule r l)]
    Just EQ -> []
    Nothing -> rule l r ++ rule r l
  where
    rule l r
      | null vs =
          [Constrained (toContext (Less r l)) (Rule l r)]
      | otherwise = rule l r' ++ rule r r'
      where
        vs = usort (vars r) \\ usort (vars l)
        -- Replace f x = g y with f x = g k, g y = g k where k is the minimal element
        r' = substf (\x -> if x `elem` vs then Fun minimal [] else Var x) r

bothSides :: (Tm f v -> Tm f v) -> Equation f v -> Equation f v
bothSides f (t :==: u) = f t :==: f u

trivial :: (Ord f, Ord v) => Equation f v -> Bool
trivial (t :==: u) = t == u

equationSize :: Sized f => Equation f v -> Int
equationSize (t :==: u) = size t `max` size u
