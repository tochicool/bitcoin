-- |
-- Stability   : experimental
-- Portability : POSIX
module Bitcoin.Util.Arbitrary.Block where

import Bitcoin.Block
import Bitcoin.Data
import Bitcoin.Util.Arbitrary.Crypto
import Bitcoin.Util.Arbitrary.Network
import Bitcoin.Util.Arbitrary.Transaction
import Bitcoin.Util.Arbitrary.Util
import qualified Data.HashMap.Strict as HashMap
import Test.QuickCheck


-- | Block full or arbitrary transactions.
arbitraryBlock :: Network -> Gen Block
arbitraryBlock net = do
    h <- arbitraryBlockHeader
    c <- choose (0, 10)
    txs <- vectorOf c (arbitraryTx net)
    return $ Block h txs


-- | Block header with random hash.
arbitraryBlockHeader :: Gen BlockHeader
arbitraryBlockHeader =
    BlockHeader
        <$> arbitrary
        <*> arbitraryBlockHash
        <*> arbitraryHash256
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary


-- | Arbitrary block hash.
arbitraryBlockHash :: Gen BlockHash
arbitraryBlockHash = BlockHash <$> arbitraryHash256


-- | Arbitrary 'GetBlocks' object with at least one block hash.
arbitraryGetBlocks :: Gen GetBlocks
arbitraryGetBlocks =
    GetBlocks
        <$> arbitrary
        <*> listOf1 arbitraryBlockHash
        <*> arbitraryBlockHash


-- | Arbitrary 'GetHeaders' object with at least one block header.
arbitraryGetHeaders :: Gen GetHeaders
arbitraryGetHeaders =
    GetHeaders
        <$> arbitrary
        <*> listOf1 arbitraryBlockHash
        <*> arbitraryBlockHash


-- | Arbitrary 'Headers' object with at least one block header.
arbitraryHeaders :: Gen Headers
arbitraryHeaders =
    Headers <$> listOf1 ((,) <$> arbitraryBlockHeader <*> arbitraryVarInt)


-- | Arbitrary 'MerkleBlock' with at least one hash.
arbitraryMerkleBlock :: Gen MerkleBlock
arbitraryMerkleBlock = do
    bh <- arbitraryBlockHeader
    ntx <- arbitrary
    hashes <- listOf1 arbitraryHash256
    c <- choose (1, 10)
    flags <- vectorOf (c * 8) arbitrary
    return $ MerkleBlock bh ntx hashes flags


-- | Arbitrary 'BlockNode'
arbitraryBlockNode :: Gen BlockNode
arbitraryBlockNode =
    BlockNode
        <$> arbitraryBlockHeader
        <*> choose (0, maxBound)
        <*> arbitrarySizedNatural
        <*> arbitraryBlockHash


-- | Arbitrary 'HeaderMemory'
arbitraryHeaderMemory :: Gen HeaderMemory
arbitraryHeaderMemory = do
    ls <- listOf $ (,) <$> arbitrary <*> arbitraryBSS
    HeaderMemory (HashMap.fromList ls) <$> arbitraryBlockNode
