{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Course.Optional where

import qualified Control.Applicative as A
import qualified Control.Monad as M
import Course.Core
import qualified Prelude as P

-- | The `Optional` data type contains 0 or 1 value.
--
-- It might be thought of as a list, with a maximum length of one.
data Optional a =
  Full a
  | Empty
  deriving (Eq, Show)

-- | Map the given function on the possible value.
--
-- >>> mapOptional (+1) Empty
-- Empty
--
-- >>> mapOptional (+1) (Full 8)
-- Full 9
mapOptional ::
  (a -> b)
  -> Optional a
  -> Optional b
mapOptional _ Empty = Empty
mapOptional f (Full a) = Full (f a)

{-
mapOptional f o =
  case o of
    Empty -> Empty
    Full a -> Full (f a)
-}

{-
mapOptional =
  \f o -> case o of
            Empty -> Empty
            Full a -> Full (f a)
-}

-- | Bind the given function on the possible value.
--
-- >>> bindOptional Full Empty
-- Empty
--
-- >>> bindOptional (\n -> if even n then Full (n - 1) else Full (n + 1)) (Full 8)
-- Full 7
--
-- >>> bindOptional (\n -> if even n then Full (n - 1) else Full (n + 1)) (Full 9)
-- Full 10
bindOptional ::
  (a -> Optional b)
  -> Optional a
  -> Optional b
bindOptional =
  \f o ->
    case o of
      Empty -> Empty
      Full x -> f x

{-

x :: a
f :: a -> Optional b
----
? :: Optional b

-}


-- | Return the possible value if it exists; otherwise, the second argument.
--
-- >>> Full 8 ?? 99
-- 8
--
-- >>> Empty ?? 99
-- 99

-- x ?? y
-- x == null ? y : x

(??) ::
  Optional a
  -> a
  -> a
(??) =
  \o a ->
    case o of
      Empty -> a
      Full x -> x

-- | Try the first optional for a value. If it has a value, use it; otherwise,
-- use the second value.
--
-- >>> Full 8 <+> Empty
-- Full 8
--
-- >>> Full 8 <+> Full 9
-- Full 8
--
-- >>> Empty <+> Full 9
-- Full 9
--
-- >>> Empty <+> Empty
-- Empty
(<+>) ::
  Optional a
  -> Optional a
  -> Optional a
Empty <+> x = x
x@(Full {}) <+> _ = x

{-
(<+>) =
  \a b ->
    case a of
      Empty -> b
      Full x -> Full x
-}

applyOptional :: Optional (a -> b) -> Optional a -> Optional b
applyOptional f a = bindOptional (\f' -> mapOptional f' a) f

twiceOptional :: (a -> b -> c) -> Optional a -> Optional b -> Optional c
twiceOptional f = applyOptional . mapOptional f

contains :: Eq a => a -> Optional a -> Bool
contains _ Empty = False
contains a (Full z) = a == z

instance P.Functor Optional where
  fmap =
    M.liftM

instance A.Applicative Optional where
  (<*>) =
    M.ap
  pure =
    Full

instance P.Monad Optional where
  (>>=) =
    flip bindOptional
  return =
    Full
