#+feature dynamic-literals
package qrcode

QR_Code :: struct {
	version:     int, // QR code version (1-40)
	error_level: Error_Level, // Error correction level
	mask:        int, // valid 0-7
	// module index 0,0 is top left of code
	modules:     [][]bool, // The QR code matrix (true = black, false = white); always square == size
	backing:     []bool, // backing memory for modules
	quiet_zone:  int, // (NOT part of the matrix; to be used by the image coverter) spec-min is 4 modules
}

// Error_Level represents the error correction level
Error_Level :: enum {
	L, // Low - 7% recovery capacity
	M, // Medium - 15% recovery capacity
	Q, // Quartile - 25% recovery capacity
	H, // High - 30% recovery capacity
}
encode_error_level :: proc(lvl: Error_Level) -> u8 {
	switch lvl {
	case .L:
		return 0b01
	case .M:
		return 0b00
	case .Q:
		return 0b11
	case .H:
		return 0b10
	}
	unreachable()
}

// EncodingMode represents the data encoding mode
Encoding_Mode :: enum u8 {
	Numeric      = 0b0001, // 1
	Alphanumeric = 0b0010, // 2
	Byte         = 0b0100, // 4
	ECI          = 0b0111, // 7
	Kanji        = 0b1000, // 8
}


Segment :: struct {
	mode:     Encoding_Mode,
	offset:   int, // offset into parent slice
	data:     []byte,
	eci_kind: ECI_Character_Set, // not used atm
	bit_cost: int, // cached
}
// not used atm:
ECI_Character_Set :: enum u32 {
	NONE             = 0,
	// ISO/IEC 646 Character Sets
	ISO_646_US       = 1, // US ASCII
	ISO_646_GB       = 2, // British ASCII
	ISO_646_FR       = 3, // French ASCII
	ISO_646_DE       = 4, // German ASCII
	ISO_646_IT       = 5, // Italian ASCII
	ISO_646_ES       = 6, // Spanish ASCII
	ISO_646_PT       = 7, // Portuguese ASCII
	ISO_646_SE       = 8, // Swedish ASCII

	// ISO/IEC 8859 Character Sets
	ISO_8859_1       = 9, // Latin-1 (Western European)
	ISO_8859_2       = 10, // Latin-2 (Central European)
	ISO_8859_3       = 11, // Latin-3 (South European)
	ISO_8859_4       = 12, // Latin-4 (North European)
	ISO_8859_5       = 13, // Cyrillic
	ISO_8859_6       = 14, // Arabic
	ISO_8859_7       = 15, // Greek
	ISO_8859_8       = 16, // Hebrew
	ISO_8859_9       = 17, // Latin-5 (Turkish)
	ISO_8859_10      = 18, // Latin-6 (Nordic)
	ISO_8859_11      = 19, // Thai
	ISO_8859_13      = 21, // Latin-7 (Baltic)
	ISO_8859_14      = 22, // Latin-8 (Celtic)
	ISO_8859_15      = 23, // Latin-9
	ISO_8859_16      = 24, // Latin-10

	// Unicode/UTF Character Sets
	UTF_8            = 26, // UTF-8

	// ISO/IEC 10646 Character Sets
	ISO_10646_UCS2   = 27, // UCS-2 (Basic Multilingual Plane)
	ISO_10646_UTF16  = 28, // UTF-16BE

	// Shift JIS Character Sets
	SHIFT_JIS        = 20, // Shift JIS (JIS X 0208 Annex 1 + JIS X 0201)

	// Windows Character Sets
	WINDOWS_1250     = 29, // Windows-1250 (Central European)
	WINDOWS_1251     = 30, // Windows-1251 (Cyrillic)
	WINDOWS_1252     = 31, // Windows-1252 (Western European)
	WINDOWS_1256     = 32, // Windows-1256 (Arabic)

	// Chinese Character Sets
	GB18030          = 33, // GB18030 (Simplified Chinese)
	BIG5             = 34, // Big5 (Traditional Chinese)

	// Korean Character Sets
	KS_X_1001        = 35, // KS X 1001 (Korean)

	// Private Use
	PRIVATE_CUSTOM_1 = 899,
	PRIVATE_CUSTOM_2 = 900,

	// Default (when no ECI is specified)
	DEFAULT          = 0,
}

Version_Data :: struct {
	id:                int,
	size:              int, // Size in modules (e.g. V1: 21x21)
	total_codewords:   int,
	remainder_bits:    int, // # of remainder bits to add after data
	alignment_centers: []int,
	encodings:         []Encoding, // typically 4 L, M, Q, H (some micro dont have H)
}
Encoding :: struct {
	level:          Error_Level,
	data_codewords: int,
	ec_codewords:   int,
	blocks:         []EC_Block,
}
EC_Block :: struct {
	p:         int, // mis-decode bytes
	no_blocks: int, // Number of blocks
	c:         int, // total bytes
	k:         int, // data bytes
	r:         int, // ecc capacity (1/2 bytes)
}
