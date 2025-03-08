package qrcode

import "core:fmt"

Bit_Stream :: struct {
	data:      [dynamic]byte,
	bit_count: int, // Total number of actual bits
}

create_bit_stream :: proc() -> Bit_Stream {
	return Bit_Stream{data = make([dynamic]byte), bit_count = 0}
}

append_bit :: proc(bs: ^Bit_Stream, bit: bool) {
	byte_index := bs.bit_count / 8
	bit_index := uint(bs.bit_count % 8)

	if byte_index >= len(bs.data) {
		append(&bs.data, 0)
	}
	if bit {
		bs.data[byte_index] |= (1 << (7 - bit_index))
	}
	bs.bit_count += 1
}
append_bits :: proc(bs: ^Bit_Stream, value: u32, count: int) {
	for i := count - 1; i >= 0; i -= 1 {
		bit := (value & (1 << u32(i))) != 0
		append_bit(bs, bit)
	}
}

destroy_bit_stream :: proc(bs: ^Bit_Stream) {
	delete(bs.data)
}
