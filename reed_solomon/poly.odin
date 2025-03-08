package reed_solomon

import "core:fmt"

Polynomial :: struct {
	data: []byte,
	orig: []byte,
}

into_poly :: proc(data: []byte, owned := false) -> (p: Polynomial) {
	if len(data) == 0 {
		return
	}

	// Find first non-zero coefficient
	non_zero_offset := 0
	for d, i in data {
		if d != 0 {
			non_zero_offset = i
			break
		}
	}

	// If all data are zero, return zero polynomial
	if non_zero_offset == len(data) - 1 {
		return
	}

	// Start at first non-zero coefficient, which can be an offset of zero
	p.data = data[non_zero_offset:]

	// Only set p.orig if data is owned, and not a slice into other memory
	if owned {
		p.orig = data
	}
	return
}

destroy_poly :: proc(p: Polynomial) {
	delete(p.orig)
}

degree :: proc(p: Polynomial) -> (res: int) {
	return len(p.data) - 1 if len(p.data) > 0 else 0
}

get_coefficient :: proc(p: Polynomial, degree: int) -> (coeff: byte, ok: bool) {
	if p.data == nil || degree < 0 || degree > len(p.data) - 1 {
		return
	}
	return p.data[len(p.data) - 1 - degree], true
}

add_poly :: proc(a, b: Polynomial, allocator := context.allocator) -> Polynomial {
	context.allocator = allocator

	a_len := len(a.data)
	b_len := len(b.data)

	if a_len == 0 {return b}
	if b_len == 0 {return a}

	max_len := max(a_len, b_len)
	result  := make([]byte, max_len)

	for ad, i in a.data {
		result[max_len - a_len + i] = ad  // Load 'a' into new poly
	}
	for bd, i in b.data {
		result[max_len - b_len + i] ~= bd // XOR for GF(2^8) addition
	}

	return into_poly(result, true) // Result is owned
}

// clones
multiply_scalar :: proc(p: ^Polynomial, scalar: byte, allocator := context.allocator) -> Polynomial {
	context.allocator = allocator

	if scalar == 0 || p.data == nil {
		return into_poly(nil)
	}

	if scalar == 1 {
		return into_poly(p.data)
	}

	result := make([]byte, len(p.data))

	for pd, i in p.data {
		result[i] = multiply(pd, scalar)
	}

	return into_poly(result, true) // owned
}

// Multiply two polynomials
multiply_poly :: proc(a, b: Polynomial, allocator := context.allocator) -> Polynomial {
	context.allocator = allocator

	if len(a.data) == 0 || len(b.data) == 0 {
		return into_poly(nil)
	}

	// Create a result polynomial with degree = deg(a) + deg(b)
	result_len := len(a.data) + len(b.data) - 1
	result := make([]byte, result_len)

	// Multiply each term
	for ad, i in a.data {
		for bd, j in b.data {
			term := multiply(ad, bd)
			result[i + j] ~= term // XOR for GF(2^8) addition
		}
	}

	return into_poly(result, true) // Owned
}

// Divide polynomials: a / b = quotient with remainder
divide_poly :: proc(a, b: Polynomial, return_quotient := false, allocator := context.allocator) -> (quotient, remainder: Polynomial, ok: bool) {
	context.allocator = allocator

	if len(b.data) == 0 || b.data[0] == 0 {
		fmt.eprintln("Error: Division by zero polynomial")
		ok = false
		return
	}
	if a.data == nil {
		return into_poly(nil), into_poly(nil), true
	}

	// Copy a's data for the remainder
	remainder_coeffs := make([]byte, len(a.data))
	copy(remainder_coeffs, a.data)
	remainder = into_poly(remainder_coeffs, true) // owned

	// If a's degree is less than b's, quotient is 0 and remainder is a
	if degree(remainder) < degree(b) {
		return into_poly(nil), remainder, true
	}

	// Calculate the quotient's size
	quotient_degree := degree(remainder) - degree(b)
	quotient_coeffs := make([]byte, quotient_degree + 1)

	// Get the leading coefficient of divisor
	normalizer, iok := inverse(b.data[0])
	if !iok {
		fmt.eprintln("Error: Cannot invert leading coefficient")
		ok = false
		return
	}

	// Polynomial long division
	for remainder_degree := degree(remainder); remainder_degree >= degree(b); {
		if remainder.data[0] == 0 {
			// Move to next term
			remainder.data = remainder.data[1:]
			continue
		}

		// Calculate quotient term
		coef := multiply(remainder.data[0], normalizer)
		quotient_pos := remainder_degree - degree(b)
		quotient_coeffs[quotient_pos] = coef

		// Subtract b * coef from remainder
		for i in 0 ..< len(b.data) {
			idx := i
			if idx < len(remainder.data) {
				remainder.data[idx] ~= multiply(b.data[i], coef)
			}
		}

		// Update remainder
		remainder.data = remainder.data[1:] // Nix terms as we are able to do long-division steps
		remainder_degree = degree(remainder)
	}
	if return_quotient {
		quotient = into_poly(quotient_coeffs, true) // Owned
	} else {
		delete(quotient_coeffs)
	}

	return quotient, remainder, true
}

// Evaluate the polynomial at a point
evaluate :: proc(p: Polynomial, x: byte) -> (res: byte, ok: bool) {
	if p.data == nil {
		return
	}

	// Horner's method for polynomial evaluation
	for pd in p.data {
		// result = result * x + coefficient
		res = add(multiply(res, x), pd)
	}

	return res, true
}

// Generate generator polynomial for Reed-Solomon encoding
generate_generator :: proc(degree: int, allocator := context.allocator) -> Polynomial {
	context.allocator = allocator

	// Start with (x + a^0)
	g := into_poly([]byte{1, exp_table[0]})

	// Multiply by (x + a^i) for i from 1 to degree-1
	for i in 1 ..< degree {
		term := into_poly([]byte{1, exp_table[i]})
		tmp  := multiply_poly(g, term, allocator)

		destroy_poly(g) // safe-deletes
		g = tmp
	}

	return g
}

// Encode message using Reed-Solomon
encode_rs :: proc(message: []byte, ec_bytes: int, allocator := context.allocator) -> (res: []byte) {
	context.allocator = allocator

	if ec_bytes == 0 {return message}

	generator := generate_generator(ec_bytes)
	message_poly := into_poly(message)
	defer destroy_poly(generator)

	// Multiply by x^(ec_bytes)
	x_ec := make([]byte, ec_bytes + 1)
	x_ec[0] = 1 // x^(ec_bytes)
	x_poly := into_poly(x_ec, true)
	defer destroy_poly(x_poly)
	extended_message := multiply_poly(message_poly, x_poly)
	defer destroy_poly(extended_message)

	_, remainder, div_ok := divide_poly(extended_message, generator)
	assert(div_ok)
	defer destroy_poly(remainder)

	res = make([]byte, ec_bytes)

	// Fill in the error correction bytes
	rem_offset := max(0, len(remainder.data) - ec_bytes)
	for i in 0 ..< min(ec_bytes, len(remainder.data)) {
		res[i] = remainder.data[rem_offset + i]
	}

	return
}

to_string :: proc(p: ^Polynomial, allocator := context.allocator) -> string {
	context.allocator = allocator

	if len(p.data) == 0 {return "0"}

	result := ""
	for i := 0; i < len(p.data); i += 1 {
		coef := p.data[i]
		if coef == 0 {continue}

		degree := len(p.data) - 1 - i

		if len(result) > 0 {result = fmt.aprintf("%s + ", result)}

		if degree == 0 {
			result = fmt.aprintf("%s%d", result, coef)
		} else if degree == 1 {
			if coef == 1 {
				result = fmt.aprintf("%sx", result)
			} else {
				result = fmt.aprintf("%s%dx", result, coef)
			}
		} else {
			if coef == 1 {
				result = fmt.aprintf("%sx^%d", result, degree)
			} else {
				result = fmt.aprintf("%s%dx^%d", result, coef, degree)
			}
		}
	}
	return result
}

import "core:log"
import "core:slice"
import "core:testing"

Test_Vector :: struct {
	message: []byte, // Input
	ecc:     []byte, // Expected ECC output
}

test_vectors := []Test_Vector{
	{ // 4-byte message with 4 ECC bytes
		{0x40, 0xd2, 0x75, 0x47}, // 64, 210, 117, 71
		{0x55, 0x7e, 0xb6, 0x3d}, // 85, 126, 182, 61
	},
	{ // Test case 2: QR code typical message
		{0x40, 0xd2, 0x75, 0x47, 0x76, 0x17, 0x32, 0x06, 0x27, 0x26, 0x96, 0xc6, 0xc6, 0x96, 0x70, 0xec},
		{0xbc, 0x2a, 0x90, 0x13, 0x6b, 0xaf, 0xef, 0xfd, 0x4b, 0xe0},
	},
}

@(test)
test_reed_solomon :: proc(t: ^testing.T) {
	for test, i in test_vectors {
		ecc := encode_rs(test.message, len(test.ecc))
		defer delete(ecc)

		passed := slice.equal(test.ecc, ecc)
		testing.expectf(t, passed, "Expected %v to equal %v", ecc, test.ecc)

		log.infof("Test case %v %v", i + 1, "passed" if passed else "failed")
		log.info("Message:     ", test.message)
		log.info("Expected ECC:", test.ecc)
		log.info("Actual ECC:  ", ecc)
	}
}