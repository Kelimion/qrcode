package reed_solomon

import "core:fmt"

QR_CODE_POLY :: 0x11D // x^8 + x^4 + x^3 + x^2 + 1

exp_table: [256]byte
log_table: [256]byte

@(init)
init_gf256 :: proc() {
	x: u16 = 1
	for i in 0 ..< 256 {
		exp_table[i] = u8(x)

		x <<= 1 // Multiply by 2 (left shift)

		// If overflow, XOR with the reduction polynomial
		if x & 0x100 != 0 {
			x ~= QR_CODE_POLY
		}
	}
	// Initialize log table (inverse of exp table)
	for i in 0 ..< 255 {
		log_table[exp_table[i]] = u8(i)
	}
	log_table[0] = 0 // set 0
}

add :: proc(a, b: byte) -> byte {
	return a ~ b // Addition in GF(2^8) is just XOR
}

subtract :: proc(a, b: byte) -> byte {
	return a ~ b // Subtraction in GF(2^8) is the same as addition
}

multiply :: proc(a, b: byte) -> byte {
	if a == 0 || b == 0 {return 0}
	log_a := u16(log_table[a])
	log_b := u16(log_table[b])
	return exp_table[(log_a + log_b) % 255]
}

inverse :: proc(a: byte) -> (byte, bool) {
	if a == 0 {return 0, false}
	log_a := u16(log_table[a])
	return exp_table[255 - log_a], true
}

divide :: proc(a, b: byte) -> (byte, bool) {
	if b == 0 {return 0, false}
	if a == 0 {return 0, true}
	log_a := u16(log_table[a])
	log_b := u16(log_table[b])
	return exp_table[(log_a + 255 - log_b) % 255], true
}

power :: proc(a: byte, power: int) -> byte {
	if a == 0 {return 0}
	log_a := u16(log_table[a])
	return exp_table[(log_a * u16(power)) % 255]
}
