(module
   (import "env" "caml_int32_format"
      (func $caml_int32_format (param (ref eq) (ref eq)) (result (ref eq))))
   (import "env" "Int32_val" (func $Int32_val (param (ref eq)) (result i32)))
   (import "env" "caml_copy_int32"
      (func $caml_copy_int32 (param i32) (result (ref eq))))
   (import "env" "caml_int64_format"
      (func $caml_int64_format
         (param (ref eq)) (param (ref eq)) (result (ref eq))))
   (import "env" "caml_copy_int64"
      (func $caml_copy_int64 (param i64) (result (ref eq))))
   (import "env" "Int64_val"
      (func $Int64_val (param (ref eq)) (result i64)))
   (import "env" "caml_failwith" (func $caml_failwith (param (ref eq))))
   (import "env" "caml_i64_of_digits"
      (func $caml_i64_of_digits
         (param i32 i32 i32 (ref $string) i32 (ref $string)) (result i64)))
   (import "env" "parse_sign_and_base"
      (func $parse_sign_and_base
         (param (ref $string)) (result i32 i32 i32 i32)))
   (import "env" "caml_serialize_int_4"
      (func $caml_serialize_int_4 (param (ref eq)) (param i32)))
   (import "env" "caml_deserialize_int_4"
      (func $caml_deserialize_int_4 (param (ref eq)) (result i32)))
   (import "env" "caml_serialize_int_8"
      (func $caml_serialize_int_8 (param (ref eq)) (param i64)))
   (import "env" "caml_deserialize_int_8"
      (func $caml_deserialize_int_8 (param (ref eq)) (result i64)))
   (import "env" "caml_raise_zero_divide"
      (func $caml_raise_zero_divide))

   (type $string (array (mut i8)))

   (func (export "integers_uint8_of_string")
      (param $v (ref eq)) (result (ref eq))
      (local $res i64)
      (local.set $res
         (call $i64_of_string (local.get $v) (i32.const 8)))
      (ref.i31 (i32.wrap_i64 (local.get $res))))

   (func (export "integers_uint16_of_string")
      (param $v (ref eq)) (result (ref eq))
      (local $res i64)
      (local.set $res
         (call $i64_of_string (local.get $v) (i32.const 16)))
      (ref.i31 (i32.wrap_i64 (local.get $res))))

   (type $compare
      (func (param (ref eq)) (param (ref eq)) (param i32) (result i32)))
   (type $hash
      (func (param (ref eq)) (result i32)))
   (type $fixed_length (struct (field $bsize_32 i32) (field $bsize_64 i32)))
   (type $serialize
      (func (param (ref eq)) (param (ref eq)) (result i32) (result i32)))
   (type $deserialize (func (param (ref eq)) (result (ref eq)) (result i32)))
   (type $dup (func (param (ref eq)) (result (ref eq))))
   (type $custom_operations
      (struct
         (field $id (ref $string))
         (field $compare (ref null $compare))
         (field $compare_ext (ref null $compare))
         (field $hash (ref null $hash))
         (field $fixed_length (ref null $fixed_length))
         (field $serialize (ref null $serialize))
         (field $deserialize (ref null $deserialize))
         (field $dup (ref null $dup))))
   (type $custom (sub (struct (field (ref $custom_operations)))))

   (global $uint32_ops (ref $custom_operations)
      (struct.new $custom_operations
         (array.new_fixed $string 15 ;; "integers:uint32"
            (i32.const 0x69) (i32.const 0x6e) (i32.const 0x74) (i32.const 0x65)
            (i32.const 0x67) (i32.const 0x65) (i32.const 0x72) (i32.const 0x73)
             (i32.const 0x3a) (i32.const 0x75) (i32.const 0x69) (i32.const 0x6e)
            (i32.const 0x74) (i32.const 0x33) (i32.const 0x32))
         (ref.func $uint32_cmp)
         (ref.null $compare)
         (ref.func $uint32_hash)
         (struct.new $fixed_length (i32.const 4) (i32.const 4))
         (ref.func $uint32_serialize)
         (ref.func $uint32_deserialize)
         (ref.func $uint32_dup)))

   (type $uint32
      (sub final $custom (struct (field (ref $custom_operations)) (field i32))))

   ;; We also redefine type int32 in order to cast before using
   ;; $caml_int32_format below.
   (type $int32
      (sub final $custom (struct (field (ref $custom_operations)) (field i32))))

   ;; We also redefine type int64 which is needed in a number of functions
   ;; below.
   (type $int64
      (sub final $custom (struct (field (ref $custom_operations)) (field i64))))

   (func $unbox_uint32 (param $v (ref eq)) (result i32)
      (struct.get $uint32 1 (ref.cast (ref $uint32) (local.get $v))))

   (func $box_uint32 (param $i i32) (result (ref eq))
      (struct.new $uint32 (global.get $uint32_ops) (local.get $i)))

   (func $uint32_cmp
      (param $v1 (ref eq)) (param $v2 (ref eq)) (param i32) (result i32)
      (local $i1 i32) (local $i2 i32)
      (local.set $i1 (call $unbox_uint32 (local.get $v1)))
      (local.set $i2 (call $unbox_uint32 (local.get $v2)))
      (i32.sub (i32.gt_u (local.get $i1) (local.get $i2))
               (i32.lt_u (local.get $i1) (local.get $i2))))

   (func $uint32_hash (param $v (ref eq)) (result i32)
      (return_call $unbox_uint32 (local.get $v)))

   (func $uint32_serialize
      (param $state (ref eq)) (param $v (ref eq)) (result i32) (result i32)
      (call $caml_serialize_int_4
        (local.get $state)
        (call $unbox_uint32 (local.get $v)))
      (tuple.make (i32.const 4) (i32.const 4)))

   (func $uint32_deserialize
      (param $state (ref eq)) (result (ref eq) i32)
      (tuple.make
         (call $box_uint32 (call $caml_deserialize_int_4 (local.get $state)))
         (i32.const 4)))

   (func $uint32_dup (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint32 (call $unbox_uint32 (local.get $v))))

   (global $INT_OF_STRING_ERRMSG (ref $string)
      (array.new_fixed $string 13 ;; "int_of_string"
         (i32.const 0x69) (i32.const 0x6e) (i32.const 0x74) (i32.const 0x5f)
         (i32.const 0x6f) (i32.const 0x66) (i32.const 0x5f) (i32.const 0x73)
         (i32.const 0x74) (i32.const 0x72) (i32.const 0x69) (i32.const 0x6e)
         (i32.const 0x67)))

   ;; Parse a string into an unsigned i64 and check that the result fits in
   ;; $bitsize bits.
   (func $i64_of_string (param $v (ref eq)) (param $bitsize i32) (result i64)
      (local $s (ref $string)) (local $t (i32 i32 i32 i32)) (local $i i32)
      (local $base i32) (local $sign i32) (local $res i64)
      (local.set $s (ref.cast (ref $string) (local.get $v)))
      (local.set $t (call $parse_sign_and_base (local.get $s)))
      (local.set $i (tuple.extract 0 (local.get $t)))
      ;; Ignore the "signedness" value returned by $parse_sign_and_base: always
      ;; pass false to $caml_i64_of_digits.
      (local.set $sign (tuple.extract 2 (local.get $t)))
      (if (i32.lt_s (local.get $sign) (i32.const 0))
         (then (call $caml_failwith (global.get $INT_OF_STRING_ERRMSG))))
      (local.set $base (tuple.extract 3 (local.get $t)))
      (local.set $res
         (call $caml_i64_of_digits (local.get $base)
                                   (i32.const 0)
                                   (i32.const 1)
                                   (local.get $s)
                                   (local.get $i)
                                   (global.get $INT_OF_STRING_ERRMSG)))
      (if (i64.gt_u (local.get $res)
                    (i64.sub
                       (i64.shl
                          (i64.const 1)
                          (i64.extend_i32_u (local.get $bitsize)))
                       (i64.const 1)))
         (then (call $caml_failwith (global.get $INT_OF_STRING_ERRMSG))))
      (local.get $res))

   (func (export "integers_uint32_of_int")
      (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i31.get_u (ref.cast (ref i31) (local.get $v)))))

   (func (export "integers_uint32_to_int")
      (param $v (ref eq)) (result (ref eq))
      (ref.i31 (call $unbox_uint32 (local.get $v))))

   (func (export "integers_uint32_add")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.add (call $unbox_uint32 (local.get $x))
                  (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_sub")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.sub (call $unbox_uint32 (local.get $x))
                  (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_mul")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.mul (call $unbox_uint32 (local.get $x))
                  (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_shift_right")
      (param $x (ref eq)) (param $shift (ref eq)) (result (ref eq))
      (local $shift_i32 i32)
      (local.set $shift_i32
         ;; We can assume $shift to be positive (result is unspecified
         ;; otherwise)
         (i31.get_u (ref.cast (ref i31) (local.get $shift))))
      (return_call $box_uint32
         (i32.shr_u (call $unbox_uint32 (local.get $x))
                    (local.get $shift_i32))))

   (func (export "integers_uint32_shift_left")
      (param $x (ref eq)) (param $shift (ref eq)) (result (ref eq))
      (local $shift_i32 i32)
      (local.set $shift_i32
         ;; We can assume $shift to be positive (result is unspecified
         ;; otherwise)
         (i31.get_u (ref.cast (ref i31) (local.get $shift))))
      (return_call $box_uint32
         (i32.shl (call $unbox_uint32 (local.get $x))
                  (local.get $shift_i32))))

   (func (export "integers_uint32_logor")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.or (call $unbox_uint32 (local.get $x))
                 (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_logand")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.and (call $unbox_uint32 (local.get $x))
                  (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_logxor")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint32
         (i32.xor (call $unbox_uint32 (local.get $x))
                  (call $unbox_uint32 (local.get $y)))))

   (func (export "integers_uint32_rem")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (local $divider i32)
      (local.set $divider (call $unbox_uint32 (local.get $y)))
      (if (i32.eqz (local.get $divider))
         (then (call $caml_raise_zero_divide)))
      (return_call $box_uint32
         (i32.rem_u (call $unbox_uint32 (local.get $x))
                    (local.get $divider))))

   (func (export "integers_uint32_div")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (local $divider i32)
      (local.set $divider (call $unbox_uint32 (local.get $y)))
      (if (i32.eqz (local.get $divider))
         (then (call $caml_raise_zero_divide)))
      (return_call $box_uint32
         (i32.div_u (call $unbox_uint32 (local.get $x))
                    (local.get $divider))))

   (func (export "integers_uint32_of_string")
      (param $v (ref eq)) (result (ref eq))
      (local $res i64)
      (local.set $res
         (call $i64_of_string (local.get $v) (i32.const 32)))
      (return_call $box_uint32 (i32.wrap_i64 (local.get $res))))

   (global $UNSIGNED_FORMAT (ref $string)
      (array.new_fixed $string 2 ;; "%u"
         (i32.const 0x25) (i32.const 0x75)))

   (global $UNSIGNED_FORMAT_HEX (ref $string)
      (array.new_fixed $string 2 ;; "%x"
         (i32.const 0x25) (i32.const 0x78)))

   (func (export "integers_uint32_to_string")
      (param $i (ref eq)) (result (ref eq))
      ;; Resort to caml_int32_format, which we know will work even on
      ;; arguments greater than Int32.max_int.
      (call $caml_int32_format
         (global.get $UNSIGNED_FORMAT)
         (ref.cast (ref $int32) (local.get $i))))

   (func (export "integers_uint32_to_hexstring")
      (param $i (ref eq)) (result (ref eq))
      ;; Resort to caml_int32_format, which we know will work even on
      ;; arguments greater than Int32.max_int.
      (call $caml_int32_format
         (global.get $UNSIGNED_FORMAT_HEX)
         (ref.cast (ref $int32) (local.get $i))))

   (func (export "integers_uint32_to_int64")
      (param $v (ref eq)) (result (ref eq))
      (return_call $caml_copy_int64
         (i64.extend_i32_u (call $unbox_uint32 (local.get $v)))))

   (func (export "integers_uint32_of_int64")
      (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint32 (i32.wrap_i64 (call $Int64_val (local.get $v)))))

   (func (export "integers_uint32_of_int32")
      (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint32 (call $Int32_val (local.get $v))))

   (func (export "integers_int32_of_uint32")
      (param $v (ref eq)) (result (ref eq))
      (return_call $caml_copy_int32 (call $unbox_uint32 (local.get $v))))

   (func (export "integers_uint32_max") (param (ref eq)) (result (ref eq))
      (call $box_uint32 (i32.const 0xffffffff)))

   (global $uint64_ops (ref $custom_operations)
      (struct.new $custom_operations
         (array.new_fixed $string 15 ;; "integers:uint64"
            (i32.const 0x69) (i32.const 0x6e) (i32.const 0x74) (i32.const 0x65)
            (i32.const 0x67) (i32.const 0x65) (i32.const 0x72) (i32.const 0x73)
             (i32.const 0x3a) (i32.const 0x75) (i32.const 0x69) (i32.const 0x6e)
            (i32.const 0x74) (i32.const 0x36) (i32.const 0x34))
         (ref.func $uint64_cmp)
         (ref.null $compare)
         (ref.func $uint64_hash)
         (struct.new $fixed_length (i32.const 8) (i32.const 8))
         (ref.func $uint64_serialize)
         (ref.func $uint64_deserialize)
         (ref.func $uint64_dup)))

   (type $uint64
      (sub final $custom (struct (field (ref $custom_operations)) (field i64))))

   (func $unbox_uint64 (param $v (ref eq)) (result i64)
      (struct.get $uint64 1 (ref.cast (ref $uint64) (local.get $v))))

   (func $box_uint64 (param $i i64) (result (ref eq))
      (struct.new $uint64 (global.get $uint64_ops) (local.get $i)))

   (func $uint64_cmp
      (param $v1 (ref eq)) (param $v2 (ref eq)) (param i32) (result i32)
      (local $i1 i64) (local $i2 i64)
      (local.set $i1 (call $unbox_uint64 (local.get $v1)))
      (local.set $i2 (call $unbox_uint64 (local.get $v2)))
      (i32.sub (i64.gt_u (local.get $i1) (local.get $i2))
               (i64.lt_u (local.get $i1) (local.get $i2))))

   (func $uint64_hash (param $v (ref eq)) (result i32)
      (local $i i64)
      (local.set $i (call $unbox_uint64 (local.get $v)))
      (i32.xor
         (i32.wrap_i64 (local.get $i))
         (i32.wrap_i64 (i64.shr_u (local.get $i) (i64.const 32)))))

   (func $uint64_serialize
      (param $state (ref eq)) (param $v (ref eq)) (result i32) (result i32)
      (call $caml_serialize_int_8
         (local.get $state)
         (call $unbox_uint64 (local.get $v)))
      (tuple.make (i32.const 8) (i32.const 8)))

   (func $uint64_deserialize
      (param $state (ref eq)) (result (ref eq)) (result i32)
      (tuple.make
         (call $box_uint64 (call $caml_deserialize_int_8 (local.get $state)))
         (i32.const 8)))

   (func $uint64_dup (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint64 (call $unbox_uint64 (local.get $v))))

   (func (export "integers_uint64_of_int")
      (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.extend_i32_u (i31.get_u (ref.cast (ref i31) (local.get $v))))))

   (func (export "integers_uint64_add")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.add
            (call $unbox_uint64 (local.get $x))
            (call $unbox_uint64 (local.get $y)))))

   (func (export "integers_uint64_sub")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.sub
            (call $unbox_uint64 (local.get $x))
            (call $unbox_uint64 (local.get $y)))))

   (func (export "integers_uint64_shift_right")
      (param $x (ref eq)) (param $shift (ref eq)) (result (ref eq))
      (local $shift_i64 i64)
      (local.set $shift_i64
         ;; We can assume $shift to be positive (result is unspecified
         ;; otherwise)
         (i64.extend_i32_u (i31.get_u (ref.cast (ref i31) (local.get $shift)))))
      (return_call $box_uint64
         (i64.shr_u (call $unbox_uint64 (local.get $x))
                    (local.get $shift_i64))))

   (func (export "integers_uint64_shift_left")
      (param $x (ref eq)) (param $shift (ref eq)) (result (ref eq))
      (local $shift_i64 i64)
      (local.set $shift_i64
         ;; We can assume $shift to be positive (result is unspecified
         ;; otherwise)
         (i64.extend_i32_u (i31.get_u (ref.cast (ref i31) (local.get $shift)))))
      (return_call $box_uint64
         (i64.shl (call $unbox_uint64 (local.get $x))
                  (local.get $shift_i64))))

   (func (export "integers_uint64_rem")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (local $divider i64)
      (local.set $divider (call $unbox_uint64 (local.get $y)))
      (if (i64.eqz (local.get $divider))
         (then (call $caml_raise_zero_divide)))
      (return_call $box_uint64
         (i64.rem_u (call $unbox_uint64 (local.get $x))
                    (local.get $divider))))

   (func (export "integers_uint64_div")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (local $divider i64)
      (local.set $divider (call $unbox_uint64 (local.get $y)))
      (if (i64.eqz (local.get $divider))
         (then (call $caml_raise_zero_divide)))
      (return_call $box_uint64
         (i64.div_u (call $unbox_uint64 (local.get $x))
                    (local.get $divider))))

   (func (export "integers_uint64_mul")
      (param $v1 (ref eq)) (param $v2 (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.mul (call $unbox_uint64 (local.get $v1))
                  (call $unbox_uint64 (local.get $v2)))))

   (func (export "integers_uint64_logxor")
      (param $v1 (ref eq)) (param $v2 (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.xor (call $unbox_uint64 (local.get $v1))
                  (call $unbox_uint64 (local.get $v2)))))

   (func (export "integers_uint64_logor")
      (param $v1 (ref eq)) (param $v2 (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.or (call $unbox_uint64 (local.get $v1))
                 (call $unbox_uint64 (local.get $v2)))))

   (func (export "integers_uint64_logand")
      (param $v1 (ref eq)) (param $v2 (ref eq)) (result (ref eq))
      (return_call $box_uint64
         (i64.and (call $unbox_uint64 (local.get $v1))
                  (call $unbox_uint64 (local.get $v2)))))

   (func (export "integers_uint64_to_string")
      (param $i (ref eq)) (result (ref eq))
      ;; Resort to caml_int64_format, which we know will work even on
      ;; arguments greater than Int64.max_int.
      (call $caml_int64_format
         (global.get $UNSIGNED_FORMAT)
         (ref.cast (ref $int64) (local.get $i))))

   (func (export "integers_uint64_to_hexstring")
      (param $i (ref eq)) (result (ref eq))
      ;; Resort to caml_int64_format, which we know will work even on
      ;; arguments greater than Int64.max_int.
      (call $caml_int64_format
         (global.get $UNSIGNED_FORMAT_HEX)
         (ref.cast (ref $int64) (local.get $i))))

   (func (export "integers_uint64_to_int")
      (param $v (ref eq)) (result (ref eq))
      (ref.i31 (i32.wrap_i64 (call $unbox_uint64 (local.get $v)))))

   (func (export "integers_uint64_of_string")
      (param $v (ref eq)) (result (ref eq))
      (local $s (ref $string)) (local $t (i32 i32 i32 i32)) (local $i i32)
      (local $base i32) (local $sign i32)
      (local.set $s (ref.cast (ref $string) (local.get $v)))
      (local.set $t (call $parse_sign_and_base (local.get $s)))
      (local.set $i (tuple.extract 0 (local.get $t)))
      ;; Ignore the "signedness" value returned by $parse_sign_and_base: always
      ;; pass false to $caml_i64_of_digits.
      (local.set $sign (tuple.extract 2 (local.get $t)))
      (if (i32.lt_s (local.get $sign) (i32.const 0))
         (then (call $caml_failwith (global.get $INT_OF_STRING_ERRMSG))))
      (local.set $base (tuple.extract 3 (local.get $t)))
      (return_call
         $box_uint64
         (call $caml_i64_of_digits (local.get $base)
                                   (i32.const 0)
                                   (i32.const 1)
                                   (local.get $s)
                                   (local.get $i)
                                   (global.get $INT_OF_STRING_ERRMSG))))

   (func (export "integers_uint64_max") (param (ref eq)) (result (ref eq))
      (call $box_uint64 (i64.const 0xffffffffffffffff)))

   (func (export "integers_uint64_of_int64")
      (param $v (ref eq)) (result (ref eq))
      (return_call $box_uint64 (call $Int64_val (local.get $v))))

   (func (export "integers_uint64_to_int64")
      (param $v (ref eq)) (result (ref eq))
      (return_call $caml_copy_int64 (call $unbox_uint64 (local.get $v))))

   (func (export "integers_ushort_size") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 2))) ;; In bytes

   (func (export "integers_uint_size") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 4))) ;; In bytes

   (func (export "integers_ulong_size") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 8))) ;; In bytes

   (func (export "integers_ulonglong_size") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 8))) ;; In bytes

   (func (export "integers_size_t_size") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 4))) ;; In bytes

   (func (export "integers_unsigned_init") (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 0)))
)
