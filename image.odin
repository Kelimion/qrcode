package qrcode

import "core:bytes"
import "core:math"
import "core:os"

// handrolled bmp generator; TODO: something better
save_qr_code_as_bmp_raw :: proc(qr: ^QR_Code, filename: string, pixels_per_module: int) -> bool {
	if qr == nil {return false}

	span := len(qr.modules)
	total_span := span + 2 * qr.quiet_zone
	actual_size := total_span * pixels_per_module
	// BMP rows must be padded to a multiple of 4 bytes
	row_size := uint(actual_size * 3 + 3) & ~uint(3)
	image_size := row_size * uint(actual_size)

	// BMP file header (14 bytes) + DIB header (40 bytes) + pixel data
	file_size := 14 + 40 + image_size

	buffer := make([]byte, file_size)
	defer delete(buffer)

	// BMP File Header (14 bytes)
	buffer[0] = 'B' // Signature 'B'
	buffer[1] = 'M' // Signature 'M'
	buffer[2] = byte(file_size & 0xFF) // File size in bytes (lowest byte)
	buffer[3] = byte((file_size >> 8) & 0xFF) // Second byte
	buffer[4] = byte((file_size >> 16) & 0xFF) // Third byte 
	buffer[5] = byte((file_size >> 24) & 0xFF) // Fourth byte (highest byte)
	// bytes 6-9 reserved (0)
	buffer[10] = 54 // Offset to start of pixel data
	// bytes 11-13 are 0

	// DIB Header (40 bytes)
	buffer[14] = 40 // Header size
	// bytes 15-17 are 0
	buffer[18] = byte(actual_size) // Width
	buffer[19] = byte(actual_size >> 8)
	buffer[20] = byte(actual_size >> 16)
	buffer[21] = byte(actual_size >> 24)
	buffer[22] = byte(actual_size) // Height
	buffer[23] = byte(actual_size >> 8)
	buffer[24] = byte(actual_size >> 16)
	buffer[25] = byte(actual_size >> 24)
	buffer[26] = 1 // Color planes
	buffer[27] = 0
	buffer[28] = 24 // Bits per pixel (24 for RGB)
	buffer[29] = 0
	// bytes 30-33 are 0 (no compression)
	buffer[34] = byte(image_size) // Image size
	buffer[35] = byte(image_size >> 8)
	buffer[36] = byte(image_size >> 16)
	buffer[37] = byte(image_size >> 24)

	// Standard resolution (72 DPI = 2835 pixels/meter)
	resolution := 2835
	buffer[38] = byte(resolution)
	buffer[39] = byte(resolution >> 8)
	buffer[40] = byte(resolution >> 16)
	buffer[41] = byte(resolution >> 24)
	buffer[42] = byte(resolution)
	buffer[43] = byte(resolution >> 8)
	buffer[44] = byte(resolution >> 16)
	buffer[45] = byte(resolution >> 24)
	// bytes 46-53 are 0 (color table info)

	// Generate the pixel data
	pixel_offset := 54 // Start of pixel data

	for y in 0 ..< actual_size {
		// In BMP, rows are stored bottom-to-top
		row := actual_size - 1 - y
		row_offset := pixel_offset + (row * int(row_size))

		for x in 0 ..< actual_size {
			// Determine which module this pixel belongs to
			module_x := x / pixels_per_module - qr.quiet_zone
			module_y := y / pixels_per_module - qr.quiet_zone

			// Determine pixel color (black or white)
			is_black := false

			// Check if we're in the actual QR code area
			if module_x >= 0 && module_x < span && module_y >= 0 && module_y < span {
				is_black = qr.modules[module_y][module_x]
			}

			// Calculate position in buffer (BGR order in BMP)
			pos := row_offset + (x * 3)

			if is_black {
				// Black (0, 0, 0)
				buffer[pos] = 0 // Blue
				buffer[pos + 1] = 0 // Green
				buffer[pos + 2] = 0 // Red
			} else {
				// White (255, 255, 255)
				buffer[pos] = 255 // Blue
				buffer[pos + 1] = 255 // Green
				buffer[pos + 2] = 255 // Red
			}
		}
	}
	return os.write_entire_file(filename, buffer)
}
