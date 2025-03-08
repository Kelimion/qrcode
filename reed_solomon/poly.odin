package reed_solomon

import "core:fmt"
import "core:mem"

Polynomial :: struct {
	data: []byte,
	ptr:  [^]byte, // holds the base ptr (some procs slice data)
	len:  int,
}


into_poly :: proc(data: []byte, own_memory := false) -> Polynomial {
	if data == nil || len(data) == 0 {return {}}

	// Find first non-zero coefficient
	first_non_zero := 0
	for i in 0 ..< len(data) {
		if data[i] != 0 {
			first_non_zero = i
			break
		}
	}
	// If all data are zero, return zero polynomial
	if first_non_zero == len(data) {return {}}
	ret_data := data
	// Remove leading zeros
	if first_non_zero > 0 {
		ret_data = data[first_non_zero:]
	}

	p := Polynomial {
		data = ret_data,
		ptr  = nil,
	}
	// only set p.ptr if this is _not_ a slice into someone else's data
	if own_memory {
		p.ptr = &p.data[0]
		p.len = len(p.data)
	}
	return p
}
destroy_poly :: proc(p: Polynomial) {
	if p.ptr != nil {
		delete(p.ptr[:p.len])
	}
}

degree :: proc(p: Polynomial) -> int {
	if p.data == nil {return 0}
	return len(p.data) - 1
}

get_coefficient :: proc(p: Polynomial, degree: int) -> (byte, bool) {
	if p.data == nil || degree < 0 || degree > len(p.data) - 1 {return 0, false}
	return p.data[len(p.data) - 1 - degree], true
}

add_poly :: proc(a, b: Polynomial, allocater := context.allocator) -> Polynomial {
	if a.data == nil || len(a.data) == 0 {return b}
	if b.data == nil || len(b.data) == 0 {return a}
	context.allocator = allocater

	result_len := max(len(a.data), len(b.data))
	result := make([]byte, result_len)

	for i in 0 ..< len(a.data) {
		result[result_len - len(a.data) + i] = a.data[i] // load 'a' into new poly
	}
	for i in 0 ..< len(b.data) {
		idx := result_len - len(b.data) + i
		result[idx] ~= b.data[i] // XOR for GF(2^8) addition
	}

	return into_poly(result, true) // res is owned
}

// clones
multiply_scalar :: proc(
	p: ^Polynomial,
	scalar: byte,
	allocater := context.allocator,
) -> Polynomial {
	if scalar == 0 || p.data == nil {return into_poly(nil)}
	if scalar == 1 {return into_poly(p.data)}
	context.allocator = allocater

	result := make([]byte, len(p.data))

	for i in 0 ..< len(p.data) {
		result[i] = multiply(p.data[i], scalar)
	}

	return into_poly(result, true) // owned
}

// Multiply two polynomials
multiply_poly :: proc(a, b: Polynomial, allocater := context.allocator) -> Polynomial {
	if a.data == nil || len(a.data) == 0 || b.data == nil || len(b.data) == 0 {
		return into_poly(nil)
	}
	context.allocator = allocater

	// Create a result polynomial with degree = deg(a) + deg(b)
	result_len := len(a.data) + len(b.data) - 1
	result := make([]byte, result_len)

	// Multiply each term
	for i in 0 ..< len(a.data) {
		for j in 0 ..< len(b.data) {
			term := multiply(a.data[i], b.data[j])
			idx := i + j
			result[idx] ~= term // XOR for GF(2^8) addition
		}
	}

	return into_poly(result, true) //owned
}

// Divide polynomials: a / b = quotient with remainder
divide_poly :: proc(
	a, b: Polynomial,
	return_quotient := false,
	allocater := context.allocator,
) -> (
	quotient, remainder: Polynomial,
	ok: bool,
) {
	if b.data == nil || len(b.data) == 0 || b.data[0] == 0 {
		fmt.eprintln("Error: Division by zero polynomial")
		ok = false
		return
	}
	if a.data == nil {return into_poly(nil), into_poly(nil), true}

	// Copy a's data for the remainder
	remainder_coeffs := make([]byte, len(a.data))
	copy(remainder_coeffs, a.data)
	remainder = into_poly(remainder_coeffs, true) // owned
	remainder_base := remainder
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
		remainder.data = remainder.data[1:] // nix terms as we are able to do long-division steps
		remainder_degree = degree(remainder)
	}
	if return_quotient {
		quotient = into_poly(quotient_coeffs, true) //owned
	} else {
		delete(quotient_coeffs)
	}

	return quotient, remainder, true
}

// Evaluate the polynomial at a point
evaluate :: proc(p: Polynomial, x: byte) -> (byte, bool) {
	if p.data == nil {return 0, false}
	// Horner's method for polynomial evaluation
	result: byte = 0
	for i := 0; i < len(p.data); i += 1 {
		// result = result * x + coefficient
		result = add(multiply(result, x), p.data[i])
	}
	return result, true
}

// Generate generator polynomial for Reed-Solomon encoding
generate_generator :: proc(degree: int, allocator := context.allocator) -> Polynomial {
	context.allocator = allocator

	// Start with (x + a^0)
	g := into_poly([]byte{1, exp_table[0]})

	// Multiply by (x + a^i) for i from 1 to degree-1
	for i in 1 ..< degree {
		term := into_poly([]byte{1, exp_table[i]})
		tmp := multiply_poly(g, term, allocator)

		destroy_poly(g) // safe-deletes
		g = tmp
	}

	return g
}

// Encode message using Reed-Solomon
encode_rs :: proc(message: []byte, ec_bytes: int, allocator := context.allocator) -> []byte {
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

	result := make([]byte, ec_bytes)

	// Fill in the error correction bytes
	rem_offset := max(0, len(remainder.data) - ec_bytes)
	for i := 0; i < min(ec_bytes, len(remainder.data)); i += 1 {
		result[i] = remainder.data[rem_offset + i]
	}

	return result
}

to_string :: proc(p: ^Polynomial, allocator := context.allocator) -> string {
	if len(p.data) == 0 {return "0"}
	context.allocator = allocator

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

import "core:testing"

@(test)
test_reed_solomon :: proc(t: ^testing.T) {

	// Test case 1: 4-byte message with 4 ECC bytes
	message1 := []byte{0x40, 0xd2, 0x75, 0x47} // 64, 210, 117, 71
	expected_ecc1 := []byte{0x55, 0x7e, 0xb6, 0x3d} // 85, 126, 182, 61

	ecc1 := encode_rs(message1, 4)
	defer delete(ecc1)
	testing.expect_value(t, len(ecc1), 4)

	for i in 0 ..< 4 {
		testing.expect_value(t, ecc1[i], expected_ecc1[i])
	}

	fmt.println("Test case 1 passed:")
	fmt.println("Message:", message1)
	fmt.println("Expected ECC:", expected_ecc1)
	fmt.println("Actual ECC:", ecc1)

	// Test case 2: QR code typical message
	message2 := []byte {
		0x40,
		0xd2,
		0x75,
		0x47,
		0x76,
		0x17,
		0x32,
		0x06,
		0x27,
		0x26,
		0x96,
		0xc6,
		0xc6,
		0x96,
		0x70,
		0xec,
	}
	expected_ecc2 := []byte{0xbc, 0x2a, 0x90, 0x13, 0x6b, 0xaf, 0xef, 0xfd, 0x4b, 0xe0}

	ecc2 := encode_rs(message2, 10)
	defer delete(ecc2)
	testing.expect_value(t, len(ecc2), 10)

	for i in 0 ..< 10 {
		testing.expect_value(t, ecc2[i], expected_ecc2[i])
	}

	fmt.println("\nTest case 2 passed:")
	fmt.println("Message:", message2)
	fmt.println("Expected ECC:", expected_ecc2)
	fmt.println("Actual ECC:", ecc2)
}
