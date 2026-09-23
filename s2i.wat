(module

  (memory (export "memory") 4)

	;; page 0: reserved
	;; page 1: input:  FoR values(512x 32-bit = 4KiB)
	;; page 2: input:  packed values(16384x 16-bit = 32KiB)
	;; page 3: output: unpacked values(16384x 32-bit = 64KiB)

	(func $short2int32x (export "short2int32x")
		(param $iptr i32)
		(param $optr i32)
		(param $rptr i32)

		(local $forv v128)

		;; input: 32x 16-bit(64B)
		;; output: 32x 32-bit(128B)

		local.get $rptr v128.load32_splat local.set $forv

		local.get $optr
		local.get $iptr v128.load16x4_s offset=0 local.get $forv i32x4.add
		v128.store offset=0

		local.get $optr
		local.get $iptr v128.load16x4_s offset=8 local.get $forv i32x4.add
		v128.store offset=16

		local.get $optr
		local.get $iptr v128.load16x4_s offset=16 local.get $forv i32x4.add
		v128.store offset=32

		local.get $optr
		local.get $iptr v128.load16x4_s offset=24 local.get $forv i32x4.add
		v128.store offset=48

		local.get $optr
		local.get $iptr v128.load16x4_s offset=32 local.get $forv i32x4.add
		v128.store offset=64

		local.get $optr
		local.get $iptr v128.load16x4_s offset=40 local.get $forv i32x4.add
		v128.store offset=80

		local.get $optr
		local.get $iptr v128.load16x4_s offset=48 local.get $forv i32x4.add
		v128.store offset=96

		local.get $optr
		local.get $iptr v128.load16x4_s offset=56 local.get $forv i32x4.add
		v128.store offset=112
	)

	(func $short2int_page (export "short2int_page")
		(param $iptr i32) ;; in:  16-bit packed values
		(param $optr i32) ;; out: 32-bit unpacked values
		(param $rptr i32) ;; in:  32-bit FoR values

		(local $i i32)
		(local $j i32)

		i32.const 512 local.set $i
		loop
			local.get $i i32.const 1 i32.sub local.set $j

			;; iptr
			local.get $iptr local.get $j i32.const 6 i32.shl i32.add
			;; optr
			local.get $optr local.get $j i32.const 7 i32.shl i32.add
			;; rptr
			local.get $rptr local.get $j i32.const 2 i32.shl i32.add
			call $short2int32x

			local.get $i i32.const 1 i32.sub local.tee $i br_if 0
		end
	)

)
