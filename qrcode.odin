package qrcode

import rs "./reed_solomon"
import "core:fmt"
import "core:mem"
import "core:strings"

main :: proc() {
	data := "https://odin-lang.org/docs/"
	qr, ok := create_code(transmute([]u8)data, .H)
	fmt.printf("qrcode: version: %v, mask:%v, ECC: %v\n", qr.version, qr.mask, qr.error_level)
	defer destroy_code(&qr)
	save_qr_code_as_bmp_raw(&qr, "./qrcode.bmp", 10)
}
///////////////////////////////////////////////////////////////////////////////////////////////
create_code :: proc(
	data: []byte,
	ecc := Error_Level.H,
	quiet_zone := 4,
) -> (
	qr: QR_Code,
	ok: bool,
) {
	segments := segment_data(data)
	defer delete(segments)
	min_version, v_ok := find_minimum_version(segments, ecc)
	if !v_ok {
		return {}, false
	}

	version_data := versions[min_version]

	qr = QR_Code {
		version     = min_version,
		error_level = ecc,
		quiet_zone  = quiet_zone,
		mask        = -1, // is set later
	}

	qr.backing, qr.modules = make_2d_slice(version_data.size, version_data.size, bool)


	bs := encode_segments_to_bitstream(segments, min_version)
	add_padding(&bs, &version_data, ecc)
	defer delete(bs.data)
	// Generate ECC; interleave the data:
	buf := process_and_interleave_stream(bs.data[:], min_version, ecc)
	defer delete(buf)

	qr.modules[len(qr.modules) - 8][8] = true // Dark Module

	set_finders(&qr)
	set_timing(&qr)
	set_alignment_patterns(&qr)
	set_version_info(&qr)

	set_data(&qr, buf)

	select_best_mask(&qr)

	set_format_info(&qr, ecc)

	return qr, true
}
destroy_code :: proc(qr: ^QR_Code) {
	delete(qr.modules)
	delete(qr.backing)
}

make_2d_slice :: proc(
	y, x: int,
	$T: typeid,
	allocator := context.allocator,
) -> (
	backing: []T,
	res: [][]T,
) {
	assert(x > 0 && y > 0)
	context.allocator = allocator

	backing = make([]T, x * y)
	res = make([][]T, y)

	for i in 0 ..< y {
		res[i] = backing[x * i:][:x]
	}
	return
}

add_padding :: proc(bs: ^Bit_Stream, version_data: ^Version_Data, ecc: Error_Level) {
	// Get the total capacity in bits for this version and ECC level
	enc := version_data.encodings[int(ecc)]
	total_capacity_bits := (enc.data_codewords) * 8

	remaining_bits := total_capacity_bits - bs.bit_count

	if remaining_bits >= 4 {
		// Add the 4-bit terminator
		append_bits(bs, 0, 4)
		remaining_bits -= 4
	} else if remaining_bits > 0 {
		// Add as many terminator bits as we can
		append_bits(bs, 0, remaining_bits)
		remaining_bits = 0
	}

	// 2. Add padding bits to align to byte boundary (0s)
	if bs.bit_count % 8 != 0 {
		padding_bits := 8 - (bs.bit_count % 8)
		append_bits(bs, 0, padding_bits)
		remaining_bits -= padding_bits
	}

	// 3. Add padding bytes alternating 0xEC and 0x11
	padding_bytes_needed := remaining_bits / 8

	for i := 0; i < padding_bytes_needed; i += 1 {
		if i % 2 == 0 {
			// Even index: add 11101100 (0xEC)
			append_bits(bs, 0xEC, 8)
		} else {
			// Odd index: add 00010001 (0x11)
			append_bits(bs, 0x11, 8)
		}
	}

	assert(bs.bit_count == total_capacity_bits, "Bit stream length doesn't match capacity")
}

set_finders :: proc(qr: ^QR_Code) {
	place_finder(qr, 0, 0) // top-left
	place_finder(qr, len(qr.modules) - 7, 0) // top-right
	place_finder(qr, 0, len(qr.modules) - 7) // bottom-left

	place_finder :: proc(qr: ^QR_Code, top_left_x, top_left_y: int) {
		// Finder pattern is a 7x7 square:
		// - Outer 7x7 black square border
		// - Middle 5x5 white square
		// - Inner 3x3 black square
		for dy in 0 ..< 7 {
			for dx in 0 ..< 7 {
				x, y := top_left_x + dx, top_left_y + dy
				// Outer black border (top, bottom, left, right edges)
				outer_border := dx == 0 || dx == 6 || dy == 0 || dy == 6
				// Inner black square (3x3 at the center)
				inner_square := dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4
				if outer_border || inner_square {
					qr.modules[y][x] = true
				}
			}
		}
	}
}

set_timing :: proc(qr: ^QR_Code) {
	// horizontal 
	for i in 8 ..< len(qr.modules) - 8 {
		qr.modules[6][i] = (i % 2 == 0) // Alternating black/white
	}
	// vertical 
	for i in 8 ..< len(qr.modules) - 8 {
		qr.modules[i][6] = (i % 2 == 0) // Alternating black/white
	}
}

set_alignment_patterns :: proc(qr: ^QR_Code) {
	if qr.version < 2 {
		return // Version 1 has none
	}
	centers := versions[qr.version].alignment_centers

	for y in centers {
		for x in centers {
			// Skip if would overlap with a finder pattern
			if (x <= 8 && y <= 8) ||
			   (x >= len(qr.modules) - 8 && y <= 8) ||
			   (x <= 8 && y >= len(qr.modules) - 8) {
				continue
			}
			set_alignment_pattern(qr, x, y)
		}
	}

	set_alignment_pattern :: proc(qr: ^QR_Code, x, y: int) {
		// Center point
		qr.modules[y][x] = true
		// Outer border (black)
		for dy in -2 ..= 2 {
			for dx in -2 ..= 2 {
				if abs(dx) == 2 || abs(dy) == 2 {
					qr.modules[y + dy][x + dx] = true
				}
			}
		}
	}
}

set_version_info :: proc(qr: ^QR_Code) {
	if qr.version < 7 {
		return // No version info for versions 1-6
	}
	version_info := get_version_info(qr.version)

	// Version info is placed in two locations:
	// 1. Below the top-right finder pattern
	// 2. To the right of the bottom-left finder pattern

	// Place version info below top-right finder pattern (3x6 modules)
	row, col := 0, len(qr.modules) - 11
	for i in 0 ..< 18 {
		bit := (version_info >> uint(i)) & 0x01
		module_value := bit == 1
		// Version info is arranged in a 3x6 block
		r := row + (i / 3)
		c := col + (i % 3)
		qr.modules[r][c] = module_value
	}

	// Place version info to the right of bottom-left finder pattern (6x3 modules)
	row, col = len(qr.modules) - 11, 0
	for i in 0 ..< 18 {
		bit := (version_info >> uint(i)) & 0x01
		module_value := bit == 1
		// Version info is arranged in a 6x3 block
		r := row + (i % 3)
		c := col + (i / 3)
		qr.modules[r][c] = module_value
	}
}

get_version_info :: proc(version: int) -> u32 {
	if version < 7 {
		return 0 // No version info for versions 1-6
	}
	// Consists of 6 data bits (the version number) followed by 12 error correction bits

	// The version number (6 bits)
	info := u32(version)

	// Calculate BCH error correction code for version information
	// The generator polynomial for version info is 0x1F25 
	generator := u32(0x1F25)

	// Shift data bits left by 12 bits (size of error correction)
	data := info << 12

	// Perform polynomial division to get error correction bits
	remainder := data
	for i: u32 = 0; i < 6; i += 1 {
		if remainder & (1 << (17 - i)) != 0 {
			remainder ~= generator << (5 - i)
		}
	}

	return (info << 12) | remainder
}

// Calculate the format information bits
// Returns a 15-bit code with error correction
get_format_info :: proc(error_level: Error_Level, mask_pattern: int) -> u16 {
	ecc_bits := u16(encode_error_level(error_level))

	// Mask pattern bits (0-7)
	mask_bits := u16(mask_pattern & 0x7)
	// Combine EC and mask bits
	data := (ecc_bits << 3) | mask_bits

	// Apply BCH error correction
	// The generator polynomial for format info is x^10 + x^8 + x^5 + x^4 + x^2 + x + 1 (0x537)
	generator := u16(0x537)

	// Shift data left by 10 bits (for error correction)
	remainder := data << 10

	// Find the remainder for BCH calculation
	// We need to check each bit position where data would have a 1
	for bit_pos: uint = 14; bit_pos >= 10; bit_pos -= 1 {
		if (remainder & (1 << bit_pos)) != 0 {
			// XOR with generator polynomial shifted to align with this bit
			remainder ~= generator << (bit_pos - 10)
		}
	}

	format_info := (data << 10) | (remainder & 0x3FF)

	// XOR with mask pattern 101010000010010 (0x5412) to ensure no all-zero format info
	format_info ~= 0x5412

	// fmt.printf("Final format info: %015b\n", format_info)
	return format_info
}

set_format_info :: proc(qr: ^QR_Code, error_level: Error_Level) {
	assert(qr.mask >= 0 && qr.mask <= 7, "Invalid Mask")
	format_info := get_format_info(error_level, qr.mask)
	size := len(qr.modules)

	// Spec Diagram: Figure 25 Iso 2015 (P56)

	// Top-left vertical portion (bits 0-5)
	for i := 0; i < 6; i += 1 {
		bit := (format_info >> uint(i)) & 1 == 1
		qr.modules[i][8] = bit
	}
	// Position of bit 6,7,8 (after timing pattern)
	qr.modules[7][8] = (format_info >> uint(6)) & 1 == 1
	qr.modules[8][8] = (format_info >> uint(7)) & 1 == 1
	qr.modules[8][7] = (format_info >> uint(8)) & 1 == 1

	// Top-left horizontal portion (bits 9-14)
	for i := 9; i <= 14; i += 1 {
		bit := (format_info >> uint(i)) & 1 == 1
		qr.modules[8][14 - i] = bit
	}

	// Top-right horizontal portion (bits 0-7)
	for i := 0; i <= 7; i += 1 {
		bit := (format_info >> uint(i)) & 1 == 1
		qr.modules[8][size - 8 + i] = bit
	}
	// Bottom-left vertical portion (bits 8-14)
	for i := 8; i <= 14; i += 1 {
		bit := (format_info >> uint(i)) & 1 == 1
		qr.modules[size - 15 + i][8] = bit
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////
is_reserved :: #force_inline proc(reserved: [][]bool, row, col: int) -> bool {
	fmt.assertf(row >= 0 && row < len(reserved), "Row OOB %v,%v", row, col)
	fmt.assertf(col >= 0 && col < len(reserved), "Col OOB %v,%v", row, col)
	return reserved[row][col]
}

build_reserved_table :: proc(qr: ^QR_Code) -> (backing: []bool, reserved: [][]bool) {
	size := len(qr.modules)
	backing, reserved = make_2d_slice(size, size, bool)

	// Mark finder patterns (including separators)
	// 7 for finder, 1 for quiet, 1 for format info = 9
	for r := 0; r < 9; r += 1 {
		for c := 0; c < 9; c += 1 {
			reserved[r][c] = true // Top-left
		}
		// nothing on TR for col after quiet, so 8
		for c := size - 8; c < size; c += 1 {
			reserved[r][c] = true // Top-right
		}
	}
	for r := size - 8; r < size; r += 1 {
		for c := 0; c < 9; c += 1 {
			reserved[r][c] = true // Bottom-left
		}
	}

	// Mark timing patterns
	for i := 0; i < size; i += 1 {
		reserved[6][i] = true // Horizontal
		reserved[i][6] = true // Vertical
	}

	// Mark alignment patterns
	if qr.version >= 2 {
		centers := versions[qr.version].alignment_centers
		for y in centers {
			if y <= 6 {continue} 	// dont write on top of finders (it pokes out into writable space)
			for x in centers {
				if x <= 6 {continue} 	// dont write on top of finders (it pokes out into writable space)
				// Mark the 5x5 area of each alignment pattern
				for dr := -2; dr <= 2; dr += 1 {
					for dc := -2; dc <= 2; dc += 1 {
						if y + dr >= 0 && y + dr < size && x + dc >= 0 && x + dc < size {
							reserved[y + dr][x + dc] = true
						}
					}
				}
			}
		}
	}

	// Mark version info areas (only in versions 7+)
	if qr.version >= 7 {
		// Version info near top-right finder
		for r := 0; r < 6; r += 1 {
			for c := size - 11; c < size - 8; c += 1 {
				reserved[r][c] = true
			}
		}
		// Version info near bottom-left finder
		for r := size - 11; r < size - 8; r += 1 {
			for c := 0; c < 6; c += 1 {
				reserved[r][c] = true
			}
		}
	}

	// Mark format info areas - CORRECTED
	// Horizontal format info (top)
	for i := 0; i < 9; i += 1 {
		reserved[8][i] = true
	}

	// Horizontal format info (right side)
	for i := size - 8; i < size; i += 1 {
		reserved[8][i] = true
	}

	// Vertical format info (left)
	for i := 0; i < 9; i += 1 {
		reserved[i][8] = true
	}

	// Vertical format info (bottom)
	for i := size - 7; i < size; i += 1 {
		reserved[i][8] = true
	}

	// Mark the fixed dark module
	reserved[8][size - 8] = true

	return
}
///////////////////////////////////////////////////////////////////////////////////////////////
// QR code data placement algorithm
set_data :: proc(qr: ^QR_Code, data: []byte) {
	size := len(qr.modules)
	backing, reserved := build_reserved_table(qr) // this copy is mutated so we cant use in future steps for masks
	defer delete(reserved)
	defer delete(backing)
	col := size - 1
	row := size - 1
	travel_up := true
	for b, i in data {
		// fmt.printf("Setting Byte: %v, r: %v, c: %v, up: %v\n", i, row, col, travel_up)
		row, col, travel_up = set_byte(qr, reserved, row, col, travel_up, b, i)
	}
}
// Upwards        Downwards
//  00 01           06 07 <- MSB
//  02 03           04 05
//  04 05           02 03
//  06 07 <- MSB    00 01

// Upward to Downward:
// Lateral         Irregular
// 02 03 04 05     00 01 02 03
// 00 01 06 07           04 05
//                       06 07

// Downward to Upward: (Ref Figure 19; 2M Symbol, cell D25, E9 is same, but goes up a number of rows)
//    07
//    06 05
//    04 03
//    02 01
// 00      

// Upward around feature:
//    00
// 01 02     Downwards; split across feature:
// 04 03       06 07
// 05 06       04 05
// 07 @@ @@ @@ @@ @@
// 00 @@          @@
// 01 @@    @@    @@
// 02 @@          @@
// 03 @@ @@ @@ @@ @@
// 04 05       02 03
// 06 07       00 01

// row, col are the 'first available' positions (data is prepared as MSB-first in the encoder)
set_byte :: proc(
	qr: ^QR_Code,
	reserved: [][]bool,
	start_row, start_col: int,
	travel_up: bool,
	data_byte: byte,
	byte_index: int,
) -> (
	next_row, next_col: int,
	next_up: bool,
) {
	size := len(qr.modules)
	bits_placed := 0
	positions := [8][2]int{} // [row, col] for each placed bit

	assert(start_col >= 0 && start_col < size, "col out of bounds")
	assert(start_row >= 0 && start_row < size, "row out of bounds")

	// Current state
	current_up := travel_up
	row := start_row
	left_col: int
	right_col: int
	is_rh_col := (size - 1 - start_col) % 2 == 0
	if start_col <= 6 {is_rh_col = !is_rh_col} 	// vertical timing line throws us off by one
	if is_rh_col {
		left_col = start_col - 1
		right_col = start_col
	} else {
		left_col = start_col
		right_col = start_col + 1
	}

	iterations := 0

	for bits_placed < 8 {
		assert(iterations < size * size, "infinite loop")
		iterations += 1

		// Direction Changes:
		if row < 0 {
			current_up = false
			row = 0
			left_col -= 2
			right_col -= 2

			// vertical timing pattern:
			if left_col == 6 {
				left_col -= 2
				right_col -= 2
			} else if right_col == 6 {
				left_col -= 1
				right_col -= 1
			}
		} else if row >= size {
			current_up = true
			row = size - 1
			left_col -= 2
			right_col -= 2
			// vertical timing pattern:
			if left_col == 6 {
				left_col -= 2
				right_col -= 2
			} else if right_col == 6 {
				left_col -= 1
				right_col -= 1
			}
		}

		if !is_reserved(reserved, row, right_col) {
			positions[bits_placed] = [2]int{row, right_col}
			reserved[row][right_col] = true // mark used
			bits_placed += 1
		}
		if bits_placed == 8 {break}
		if !is_reserved(reserved, row, left_col) {
			positions[bits_placed] = [2]int{row, left_col}
			reserved[row][left_col] = true // mark used
			bits_placed += 1
		}
		row += current_up ? -1 : 1
	}

	for i := 0; i < bits_placed; i += 1 {
		r, c := positions[i].x, positions[i].y
		// Always read bits MSB first (7 down to 0)
		bit_idx := 7 - (i % 8) // Use modulo to handle multiple bytes
		bit_value := (data_byte & (1 << uint(bit_idx))) != 0
		qr.modules[r][c] = bit_value
	}
	if row < size && row >= 0 && !is_reserved(reserved, row, left_col) {
		// we did not consume the left position
		next_row = row
		next_col = left_col
		next_up = current_up
	} else {
		if current_up {
			next_row = row - 1
			if next_row < 0 {
				next_up = false
				next_row = 0
				next_col = left_col - 2
			} else {
				// Continue upward
				next_up = true
				next_col = left_col
			}
		} else {
			next_row = row + 1
			if next_row >= size {
				next_up = true
				next_row = size - 1
				next_col = left_col - 2
			} else {
				// Continue downward
				next_up = false
				next_col = left_col
			}
		}
	}
	assert(bits_placed == 8, "failed to set full byte")
	// fmt.println("Set Byte at:", positions)
	// print_br_corner(positions, byte_index, current_up)
	return next_row, next_col, next_up
}
///////////////////////////////////////////////////////////////////////////////////////////////
// Ref ISO 18004:2015 Fig 21, (P51)
mask_pattern :: proc(mask_num: int, row, col: int) -> bool {
	switch mask_num {
	case 0:
		return (row + col) % 2 == 0
	case 1:
		return row % 2 == 0
	case 2:
		return col % 3 == 0
	case 3:
		return (row + col) % 3 == 0
	case 4:
		return (row / 2 + col / 3) % 2 == 0
	case 5:
		return (row * col) % 2 + (row * col) % 3 == 0
	case 6:
		return ((row * col) % 2 + (row * col) % 3) % 2 == 0
	case 7:
		return ((row + col) % 2 + (row * col) % 3) % 2 == 0
	case:
		return false
	}
}
select_best_mask :: proc(qr: ^QR_Code) {
	backing, reserved := build_reserved_table(qr)
	defer delete(reserved)
	defer delete(backing)

	size := len(qr.modules)

	masked_data := [8]Masked_Modules{}
	best_score: int = 1E9
	best_index: int
	for i in 0 ..< 8 {
		masked_data[i].backing, masked_data[i].modules = make_2d_slice(size, size, bool)
		copy(masked_data[i].backing, qr.backing)
		apply_mask(masked_data[i], reserved, i)
		score := calculate_penalty(masked_data[i])
		if score < best_score {
			best_score = score
			best_index = i
		}
	}
	qr.mask = best_index
	copy(qr.backing, masked_data[best_index].backing)
	for i in 0 ..< 8 {
		delete(masked_data[i].modules)
		delete(masked_data[i].backing)
	}
}
Masked_Modules :: struct {
	backing: []bool,
	modules: [][]bool,
}
apply_mask :: proc(mm: Masked_Modules, reserved: [][]bool, mask_num: int) {
	size := len(mm.modules)
	for row in 0 ..< size {
		for col in 0 ..< size {
			if is_reserved(reserved, row, col) {continue}
			// XOR the module with the mask pattern
			if mask_pattern(mask_num, row, col) {
				mm.modules[row][col] = !mm.modules[row][col]
			}
		}
	}
}
// Ref ISO18004:2015 Section 7.8.3
calculate_penalty :: proc(mm: Masked_Modules) -> int {
	size := len(mm.modules)
	score := 0
	// Rule 1: Five or more same-colored modules in a row/column
	score += penalty_consecutive_modules(mm)
	// Rule 2: Penalty for 2x2 blocks of same-colored modules
	score += penalty_2x2_blocks(mm)
	// Rule 3: Patterns similar to finder patterns
	score += penalty_finder_patterns(mm)
	// Rule 4: Balance of dark and light modules
	score += penalty_balance(mm)

	return score
}

// Rule 1: Five or more same-colored modules in a row/column
penalty_consecutive_modules :: proc(mm: Masked_Modules) -> int {
	size := len(mm.modules)
	score := 0
	// Check rows
	for row in 0 ..< size {
		count := 0
		last_module := false

		for col in 0 ..< size {
			if mm.modules[row][col] == last_module {
				count += 1
			} else {
				if count >= 5 {
					score += count - 2
				}
				count = 1
				last_module = mm.modules[row][col]
			}
		}
		if count >= 5 {
			score += count - 2
		}
	}
	// Check columns
	for col in 0 ..< size {
		count := 0
		last_module := false

		for row in 0 ..< size {
			if mm.modules[row][col] == last_module {
				count += 1
			} else {
				if count >= 5 {
					score += count - 2
				}
				count = 1
				last_module = mm.modules[row][col]
			}
		}
		if count >= 5 {
			score += count - 2
		}
	}

	return score
}

// Rule 2: Penalty for 2x2 blocks of same-colored modules
penalty_2x2_blocks :: proc(mm: Masked_Modules) -> int {
	size := len(mm.modules)
	score := 0

	for row in 0 ..< (size - 1) {
		for col in 0 ..< (size - 1) {
			module := mm.modules[row][col]
			if module == mm.modules[row + 1][col] &&
			   module == mm.modules[row][col + 1] &&
			   module == mm.modules[row + 1][col + 1] {
				score += 3
			}
		}
	}

	return score
}

// Rule 3: Patterns similar to finder patterns
penalty_finder_patterns :: proc(mm: Masked_Modules) -> int {
	size := len(mm.modules)
	score := 0

	// Pattern 1: 1:1:3:1:1 ratio (dark:light:dark:light:dark)
	// Check horizontally
	for row in 0 ..< size {
		for col in 0 ..< (size - 6) {
			if (mm.modules[row][col] &&
				   !mm.modules[row][col + 1] &&
				   mm.modules[row][col + 2] &&
				   mm.modules[row][col + 3] &&
				   mm.modules[row][col + 4] &&
				   !mm.modules[row][col + 5] &&
				   mm.modules[row][col + 6]) {
				// Check for white space on either side (if possible)
				if col >= 4 &&
				   !mm.modules[row][col - 1] &&
				   !mm.modules[row][col - 2] &&
				   !mm.modules[row][col - 3] &&
				   !mm.modules[row][col - 4] {
					score += 40
				}
				if col + 10 < size &&
				   !mm.modules[row][col + 7] &&
				   !mm.modules[row][col + 8] &&
				   !mm.modules[row][col + 9] &&
				   !mm.modules[row][col + 10] {
					score += 40
				}
			}
		}
	}

	// Check vertically
	for col in 0 ..< size {
		for row in 0 ..< (size - 6) {
			if (mm.modules[row][col] &&
				   !mm.modules[row + 1][col] &&
				   mm.modules[row + 2][col] &&
				   mm.modules[row + 3][col] &&
				   mm.modules[row + 4][col] &&
				   !mm.modules[row + 5][col] &&
				   mm.modules[row + 6][col]) {
				// Check for white space on either side (if possible)
				if row >= 4 &&
				   !mm.modules[row - 1][col] &&
				   !mm.modules[row - 2][col] &&
				   !mm.modules[row - 3][col] &&
				   !mm.modules[row - 4][col] {
					score += 40
				}
				if row + 10 < size &&
				   !mm.modules[row + 7][col] &&
				   !mm.modules[row + 8][col] &&
				   !mm.modules[row + 9][col] &&
				   !mm.modules[row + 10][col] {
					score += 40
				}
			}
		}
	}

	return score
}

// Rule 4: Balance of dark and light modules
penalty_balance :: proc(mm: Masked_Modules) -> int {
	size := len(mm.modules)
	dark_count := 0
	total_count := size * size

	for row in 0 ..< size {
		for col in 0 ..< size {
			if mm.modules[row][col] {
				dark_count += 1
			}
		}
	}

	// Calculate percentage of dark modules (in steps of 5%)
	percentage := (dark_count * 100) / total_count
	steps_from_50 := (percentage / 5) - 10 // 50% would be step 10
	if steps_from_50 < 0 {
		steps_from_50 = -steps_from_50
	}

	return steps_from_50 * 10
}
///////////////////////////////////////////////////////////////////////////////////////////////
process_and_interleave_stream :: proc(data: []byte, version: int, ecc: Error_Level) -> []byte {
	version_data := versions[version]
	enc := version_data.encodings[ecc]

	assert(len(data) == enc.data_codewords, "Data was not correctly padded")

	Block_Size :: struct {
		ec_bytes:   int,
		data_bytes: int,
		count:      int,
		start_idx:  int, // Start index in block array
	}

	// Count blocks and track block groups
	total_blocks := 0
	block_groups := make([]Block_Size, len(enc.blocks))
	defer delete(block_groups)

	for block_group, i in enc.blocks {
		block_groups[i] = Block_Size {
			ec_bytes   = block_group.r * 2 + block_group.p, // EC capacity * 2
			data_bytes = block_group.k,
			count      = block_group.no_blocks,
			start_idx  = total_blocks,
		}
		total_blocks += block_group.no_blocks
	}

	// Create data blocks array
	data_blocks := make([][]byte, total_blocks)
	defer delete(data_blocks)

	// split up the data-stream into slices per the block sizes
	data_index := 0
	block_index := 0

	for block_group in enc.blocks {
		for j in 0 ..< block_group.no_blocks {
			end_index := min(data_index + block_group.k, len(data))
			data_blocks[block_index] = data[data_index:end_index]
			data_index += block_group.k
			block_index += 1
		}
	}

	// Generate error correction codes for each block
	ec_blocks := make([][]byte, total_blocks)
	defer {
		for i in 0 ..< len(ec_blocks) {
			if ec_blocks[i] != nil {
				delete(ec_blocks[i])
			}
		}
		delete(ec_blocks)
	}

	// Calculate total EC bytes
	total_ec_bytes := 0
	for group in block_groups {
		total_ec_bytes += group.ec_bytes * group.count
	}
	// fmt.println("Block groups:", block_groups)
	// fmt.println("Expected EC:", enc.ec_codewords, "Calculated EC:", total_ec_bytes)
	assert(enc.ec_codewords == total_ec_bytes)

	// Generate EC codewords for each block using the correct EC size
	for group in block_groups {
		for i in 0 ..< group.count {
			block_idx := group.start_idx + i
			ec_blocks[block_idx] = rs.encode_rs(data_blocks[block_idx], group.ec_bytes)
		}
	}

	// Interleave data and error correction codewords
	// ISO Section 7.6; the language is really confusing. You take a byte from each block and interleave them, this scatters the data through the QR code to make error recovery easier (less likely a contiguous section of data is destroyed)
	result := make([]byte, len(data) + total_ec_bytes)

	// Find maximum block size
	max_block_size := 0
	for block in data_blocks {
		max_block_size = max(max_block_size, len(block))
	}

	// Interleave data codewords
	result_index := 0
	for i in 0 ..< max_block_size {
		for j in 0 ..< total_blocks { 	// #ecc blocks == #data blocks
			if i < len(data_blocks[j]) {
				result[result_index] = data_blocks[j][i]
				result_index += 1
			}
		}
	}

	// Find maximum EC block size
	max_ec_size := 0
	for block in ec_blocks {
		max_ec_size = max(max_ec_size, len(block))
	}

	// Interleave error correction codewords
	for i in 0 ..< max_ec_size {
		for j in 0 ..< total_blocks {
			if i < len(ec_blocks[j]) {
				result[result_index] = ec_blocks[j][i]
				result_index += 1
			}
		}
	}

	return result
}
