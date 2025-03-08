package qrcode

import "core:fmt"
import "core:unicode/utf8"
/////////////////////////////////////////////////////////////////////////////////////////////
// Greedy Solver - maybe switch to DP ??
// TODO: ISO18004:2015 Annex J has a suggested algo; didnt see until was done.. compare encoding-perf to mine
segment_data :: proc(data: []byte) -> []Segment {
	if len(data) == 0 {
		return nil
	}

	Encoded_Index :: struct {
		index: int,
		mode:  Encoding_Mode,
	}

	// First pass: Identify mode change indices
	mode_changes := make([dynamic]Encoded_Index)
	defer delete(mode_changes)

	i := 0
	r, size := utf8.decode_rune_in_bytes(data[i:])
	current_mode := determine_mode_for_rune(r)
	append(&mode_changes, Encoded_Index{0, current_mode})
	i += size

	for i < len(data) {
		r, size = utf8.decode_rune_in_bytes(data[i:])

		// If it's an invalid UTF-8 sequence, treat it as a single byte
		if r == utf8.RUNE_ERROR && size == 1 {
			optimal_mode := Encoding_Mode.Byte

			if optimal_mode != current_mode {
				append(&mode_changes, Encoded_Index{i, optimal_mode})
				current_mode = optimal_mode
			}

			i += 1
		} else {
			// Valid UTF-8 sequence
			optimal_mode := determine_mode_for_rune(r)

			if optimal_mode != current_mode {
				append(&mode_changes, Encoded_Index{i, optimal_mode})
				current_mode = optimal_mode
			}

			i += size
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Second pass: Generate lowest-cost segments
	segments := make([dynamic]Segment)

	if len(mode_changes) == 0 {
		return segments[:]
	}

	for i := 0; i < len(mode_changes); i += 1 {
		current_change := mode_changes[i]
		current_start := current_change.index
		current_mode := current_change.mode

		// Calculate end index
		current_end := len(data)
		if i + 1 < len(mode_changes) {
			current_end = mode_changes[i + 1].index
		}

		current_segment := Segment {
			mode   = current_mode,
			offset = current_start,
			data   = data[current_start:current_end],
		}

		current_cost := calculate_segment_bits(current_segment)
		current_segment.bit_cost = current_cost

		if len(segments) > 0 {
			prev_segment := &segments[len(segments) - 1]

			// If same mode or merging would be cheaper, merge
			if prev_segment.mode == current_mode {
				prev_segment.data = data[prev_segment.offset:current_end]
				// Recalculate the bit cost for the extended segment
				prev_segment.bit_cost = calculate_segment_bits(prev_segment^)
				continue
			}

			// Check if merging would be cheaper
			merged_data := data[prev_segment.offset:current_end]
			best_mode := determine_best_mode_for_data(merged_data)

			merged_segment := Segment {
				mode   = best_mode,
				offset = prev_segment.offset,
				data   = merged_data,
			}

			merged_cost := calculate_segment_bits(merged_segment)
			merged_segment.bit_cost = merged_cost

			separate_cost := prev_segment.bit_cost + current_cost

			if merged_cost < separate_cost {
				// Merging is cheaper, update previous segment
				prev_segment^ = merged_segment
				continue
			}
		}

		// Add as a new segment
		append(&segments, current_segment)
	}

	return segments[:]
}

calculate_segment_bits :: proc(segment: Segment, version := 40) -> int {
	// Mode indicator (4 bits)
	total_bits := 4

	switch segment.mode {
	case .Numeric:
		if version >= 1 && version <= 9 {
			total_bits += 10
		} else if version >= 10 && version <= 26 {
			total_bits += 12
		} else {
			total_bits += 14
		}

		// Data bits
		digit_count := len(segment.data)
		total_bits += (digit_count / 3) * 10

		remainder := digit_count % 3
		if remainder == 1 {
			total_bits += 4
		} else if remainder == 2 {
			total_bits += 7
		}

	case .Alphanumeric:
		if version >= 1 && version <= 9 {
			total_bits += 9
		} else if version >= 10 && version <= 26 {
			total_bits += 11
		} else {
			total_bits += 13
		}

		// Data bits
		char_count := len(segment.data)
		total_bits += (char_count / 2) * 11

		if char_count % 2 == 1 {
			total_bits += 6
		}

	case .Byte:
		if version >= 1 && version <= 9 {
			total_bits += 8
		} else {
			total_bits += 16
		}

		// Data bits
		total_bits += len(segment.data) * 8

	case .Kanji:
		if version >= 1 && version <= 9 {
			total_bits += 8
		} else if version >= 10 && version <= 26 {
			total_bits += 10
		} else {
			total_bits += 12
		}

		// Data bits (assuming 2 bytes per Kanji character)
		total_bits += (len(segment.data) / 2) * 13

	case .ECI:
		// ECI indicator (no character count)
		// ECI assignment number (8, 16, or 24 bits)
		eci_value := u32(segment.eci_kind)

		if eci_value <= 127 {
			total_bits += 8
		} else if eci_value <= 16383 {
			total_bits += 16
		} else {
			total_bits += 24
		}

		// Data bits (typically in Byte mode)
		total_bits += len(segment.data) * 8
	}

	return total_bits
}

determine_best_mode_for_data :: proc(data: []byte) -> Encoding_Mode {
	is_numeric := true
	for b in data {
		if b < '0' || b > '9' {
			is_numeric = false
			break
		}
	}

	if is_numeric {
		return .Numeric
	}

	// Check if all characters are alphanumeric
	is_alpha := true
	for b in data {
		if !is_alphanumeric(b) {
			is_alpha = false
			break
		}
	}

	if is_alpha {
		return .Alphanumeric
	}

	// TODO: Kanji/ECI

	return .Byte
}

is_alphanumeric :: proc(b: byte) -> bool {
	if b >= '0' && b <= '9' {return true}
	if b >= 'A' && b <= 'Z' {return true} 	// NOTE: QR-Code does _not_ recognize a-z as alpha
	switch b {
	case ' ', '$', '%', '*', '+', '-', '.', '/', ':':
		return true
	}
	return false
}

/////////////////////////////////////////////////////////////////////////////////////////////
find_minimum_version :: proc(
	segments: []Segment,
	ecc: Error_Level,
) -> (
	min_version: int,
	ok: bool,
) {
	total_bits := 0
	for s in segments {
		total_bits += s.bit_cost
	}
	for i := 1; i <= 40; i += 1 {
		min_version = i
		version_data := versions[i]
		enc := version_data.encodings[int(ecc)]
		avail_bits := enc.data_codewords * 8

		if total_bits <= avail_bits {
			break
		}
		if i == 40 {
			return -1, false
		}
	}
	starting_min_version := min_version
	// Recompute costs to see if we can reduce the version level
	if min_version > 1 {
		for test_version := min_version - 1; test_version >= 1; test_version -= 1 {
			version_data := versions[test_version]
			enc := version_data.encodings[int(ecc)]
			avail_bits := enc.data_codewords * 8

			recalc_total_bits := 0
			for &s in segments {
				recalc_total_bits += calculate_segment_bits(s, test_version)
			}

			if recalc_total_bits <= avail_bits {
				min_version = test_version
			} else {
				break
			}
		}
	}
	// save the new version costs into the segments (TODO: do we even need this once min version is known??)
	if starting_min_version != min_version {
		for &s in segments {
			s.bit_cost = calculate_segment_bits(s, min_version)
		}
	}
	return min_version, true
}
// Ref ISO 18004:2015, Section 7.4, Table 3
get_character_count_bits :: proc(mode: Encoding_Mode, version: int) -> int {
	if version >= 1 && version <= 9 {
		#partial switch mode {
		case .Numeric:
			return 10
		case .Alphanumeric:
			return 9
		case .Byte:
			return 8
		case .Kanji:
			return 8
		case:
			unreachable()
		}
	} else if version >= 10 && version <= 26 {
		#partial switch mode {
		case .Numeric:
			return 12
		case .Alphanumeric:
			return 11
		case .Byte:
			return 16
		case .Kanji:
			return 10
		case:
			unreachable()
		}
	} else if version >= 27 && version <= 40 {
		#partial switch mode {
		case .Numeric:
			return 14
		case .Alphanumeric:
			return 13
		case .Byte:
			return 16
		case .Kanji:
			return 12
		case:
			unreachable()
		}
	}
	unreachable()
}

/////////////////////////////////////////////////////////////////////////////////////////////
encode_segments_to_bitstream :: proc(segments: []Segment, version: int) -> Bit_Stream {
	bs := create_bit_stream()

	for segment in segments {
		// 1. Append mode indicator (4 bits)
		append_bits(&bs, u32(segment.mode), 4)
		// fmt.printf("Mode Bits: 0b%b (as enum:%v)\n", u8(segment.mode), segment.mode)
		// 2. Append character count indicator
		count_bits := get_character_count_bits(segment.mode, version)
		append_bits(&bs, u32(len(segment.data)), count_bits)

		// 3. Append data bits based on encoding mode
		switch segment.mode {
		case .Numeric:
			encode_numeric(&bs, segment.data)
		case .Alphanumeric:
			encode_alphanumeric(&bs, segment.data)
		case .Byte:
			encode_byte(&bs, segment.data)
		case .Kanji:
			encode_kanji(&bs, segment.data)
		case .ECI:
			encode_eci(&bs, segment)
		case:
			unreachable()
		}
	}

	return bs
}

encode_numeric :: proc(bs: ^Bit_Stream, data: []byte) {
	// Process groups of 3 digits
	i := 0
	for i < len(data) {
		count := min(3, len(data) - i)
		value: u32 = 0

		// Convert digits to value
		for j := 0; j < count; j += 1 {
			value = value * 10 + u32(data[i + j] - '0')
		}

		bit_count := 0
		if count == 3 {
			bit_count = 10
		} else if count == 2 {
			bit_count = 7
		} else {
			bit_count = 4
		}

		append_bits(bs, value, bit_count)
		i += count
	}
}

encode_alphanumeric :: proc(bs: ^Bit_Stream, data: []byte) {
	// Process pairs of characters
	i := 0
	for i < len(data) {
		if i + 1 < len(data) {
			// Process a pair
			value1 := get_alphanumeric_value(data[i])
			value2 := get_alphanumeric_value(data[i + 1])
			value := value1 * 45 + value2
			append_bits(bs, u32(value), 11)
			i += 2
		} else {
			// Process a single character
			value := get_alphanumeric_value(data[i])
			append_bits(bs, u32(value), 6)
			i += 1
		}
	}
}

encode_byte :: proc(bs: ^Bit_Stream, data: []byte) {
	// Each byte is encoded as 8 bits
	for b in data {
		// fmt.printf("Encoding byte: 0x%02X (%c) - bits: %08b\n", b, b, b)
		append_bits(bs, u32(b), 8)

		// Debug: Print current bit stream state
		// fmt.printf("Bit stream after adding byte: ")
		// for i := 0; i < len(bs.data); i += 1 {
		// 	fmt.printf("%08b ", bs.data[i])
		// }
		// fmt.printf("(bit count: %d)\n", bs.bit_count)
	}
}

encode_kanji :: proc(bs: ^Bit_Stream, data: []byte) {
	unimplemented()

	// // Process pairs of bytes (each Kanji character)
	// for i := 0; i < len(data); i += 2 {
	// 	// Combine two bytes into a 16-bit value
	// 	value := (u32(data[i]) << 8) | u32(data[i + 1])

	// 	// Convert to QR code Kanji value (implementation depends on your Kanji encoding)
	// 	qr_value := convert_to_qr_kanji(value)

	// 	// Append 13 bits
	// 	append_bits(bs, qr_value, 13)
	// }
}

encode_eci :: proc(bs: ^Bit_Stream, segment: Segment) {
	unimplemented()
	// // Append ECI assignment number
	// eci_value := u32(segment.eci_kind)

	// if eci_value <= 127 {
	// 	append_bits(bs, eci_value, 8)
	// } else if eci_value <= 16383 {
	// 	append_bits(bs, 0x8000 | eci_value, 16)
	// } else {
	// 	append_bits(bs, 0xC00000 | eci_value, 24)
	// }

	// // Encode the data in byte mode
	// encode_byte(bs, segment.data)
}

get_alphanumeric_value :: proc(char: byte) -> int {
	// QR code alphanumeric character set mapping
	if char >= '0' && char <= '9' {
		return int(char - '0') // 0-9 map to values 0-9
	} else if char >= 'A' && char <= 'Z' {
		return int(char - 'A') + 10 // A-Z map to values 10-35
	} else {
		// Special characters
		switch char {
		case ' ':
			return 36
		case '$':
			return 37
		case '%':
			return 38
		case '*':
			return 39
		case '+':
			return 40
		case '-':
			return 41
		case '.':
			return 42
		case '/':
			return 43
		case ':':
			return 44
		case:
			unreachable()
		}
	}
}

determine_mode_for_rune :: proc(r: rune) -> Encoding_Mode {
	// QR code alphanumeric set: 0-9, A-Z, space, $, %, *, +, -, ., /, :
	if r >= '0' && r <= '9' {
		return .Numeric
	}
	switch r {
	case 'A' ..= 'Z', ' ', '$', '%', '*', '+', '-', '.', '/', ':':
		return .Alphanumeric
	}

	// Check if it's a Kanji character
	if is_kanji_rune(r) {
		return .Kanji
	}
	// Default to byte mode
	return .Byte
}


is_kanji_rune :: proc(r: rune) -> bool {
	// TODO: check against the Shift JIS encoding
	// For now, we'll just check if it's in the CJK Unified Ideographs block
	return r >= 0x4E00 && r <= 0x9FFF
}
