package qrcode

import "core:fmt"
import "core:strings"

make_printable_grid :: proc(reserved: [][]bool) -> [][]rune {
	_, grid := make_2d_slice(len(reserved), len(reserved), rune)

	for y in 0 ..< len(reserved) {
		for x in 0 ..< len(reserved) {
			if reserved[y][x] {
				grid[y][x] = 'X'
			} else {
				grid[y][x] = '_'
			}
		}
	}
	return grid
}

print_grid :: proc(grid: [][]rune) {
	sb := strings.builder_make()
	for row in grid {
		for col in row {
			strings.write_rune(&sb, col)
		}
		strings.write_rune(&sb, '\n')
	}
	fmt.println(strings.to_string(sb))
}

print_version :: proc(v: Version_Data, ecc: Error_Level) {
	fmt.printf("Version: %v\n", v.id)
	fmt.printf("Size: %v\n", v.size)
	fmt.printf("total_codewords: %v\n", v.total_codewords)
	fmt.printf("remainder_bits: %v\n", v.remainder_bits)
	fmt.printf("alignment_centers: %v\n", v.alignment_centers)
	enc := v.encodings[int(ecc)]
	fmt.printf("%#v\n", enc)

}

// debug helper to see the bounding box of a emplaced byte
print_br_corner :: proc(p: [8][2]int, i: int, current_up: bool) {
	min_x := 999
	min_y := 999
	max_x := 0
	max_y := 0
	for b in p {
		if b.x > max_x {max_x = b.x}
		if b.y > max_y {max_y = b.y}
		if b.x < min_x {min_x = b.x}
		if b.y < min_y {min_y = b.y}
	}
	fmt.printf(
		"Byte %v Range: %v,%v to %v,%v; up: %v\n",
		i,
		min_x,
		min_y,
		max_x,
		max_y,
		current_up,
	)
}
