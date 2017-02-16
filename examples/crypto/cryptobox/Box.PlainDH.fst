(**
   TODO: Documentation.
*)
module Box.PlainDH

open CoreCrypto
open Platform.Bytes
open Box.Flags
open Box.Indexing
open Box.AE

type key = AE.key

let ae_key_get_index = AE.get_index

let keygen = AE.keygen

let coerce_key = AE.coerce_key

let leak_key = AE.leak_key

let ae_key_region = AE.ae_key_region

let leak_regionGT = AE.leak_regionGT

let leak_logGT = AE.leak_logGT

let recall_log = AE.recall_log
