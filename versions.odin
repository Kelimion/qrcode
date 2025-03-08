#+feature dynamic-literals
package qrcode
// Ref ISO 18004:2015, Tables 7 & 9, mostly
// Note: Table 9 is really confusing, to get the # of encoding blocks you take the last 2 from the list and work backwards
// They show 5H, its the last two entries; 5Q is the next two 5M is the previous 1 and 5L is the first
// (there are 6 total)

// TODO: version 31+ i got tired of typing so c,k,r are all empty

// R needs *=2 for use; 
versions := []Version_Data {
	{}, // allow for one-indexing
	Version_Data {
		id = 1,
		size = 21,
		total_codewords = 26,
		remainder_bits = 0,
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 19,
				ec_codewords = 7,
				blocks = {EC_Block{p = 3, no_blocks = 1, c = 26, k = 19, r = 2}},
			},
			Encoding {
				level = .M,
				data_codewords = 16,
				ec_codewords = 10,
				blocks = {EC_Block{p = 2, no_blocks = 1, c = 26, k = 16, r = 4}},
			},
			Encoding {
				level = .Q,
				data_codewords = 13,
				ec_codewords = 13,
				blocks = {EC_Block{p = 1, no_blocks = 1, c = 26, k = 13, r = 6}},
			},
			Encoding {
				level = .H,
				data_codewords = 9,
				ec_codewords = 17,
				blocks = {EC_Block{p = 1, no_blocks = 1, c = 26, k = 9, r = 8}},
			},
		},
	},
	Version_Data {
		id = 2,
		size = 25,
		total_codewords = 44,
		remainder_bits = 7,
		alignment_centers = {6, 18},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 34,
				ec_codewords = 10,
				blocks = {EC_Block{p = 2, no_blocks = 1, c = 44, k = 34, r = 4}},
			},
			Encoding {
				level = .M,
				data_codewords = 28,
				ec_codewords = 16,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 44, k = 28, r = 8}},
			},
			Encoding {
				level = .Q,
				data_codewords = 22,
				ec_codewords = 22,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 44, k = 22, r = 11}},
			},
			Encoding {
				level = .H,
				data_codewords = 16,
				ec_codewords = 28,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 44, k = 16, r = 14}},
			},
		},
	},
	Version_Data {
		id = 3,
		size = 29,
		total_codewords = 70,
		remainder_bits = 7,
		alignment_centers = {6, 22},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 55,
				ec_codewords = 15,
				blocks = {EC_Block{p = 1, no_blocks = 1, c = 70, k = 55, r = 7}},
			},
			Encoding {
				level = .M,
				data_codewords = 44,
				ec_codewords = 26,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 70, k = 44, r = 13}},
			},
			Encoding {
				level = .Q,
				data_codewords = 34,
				ec_codewords = 36,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 35, k = 17, r = 9}},
			},
			Encoding {
				level = .H,
				data_codewords = 26,
				ec_codewords = 44,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 35, k = 13, r = 11}},
			},
		},
	},
	Version_Data {
		id = 4,
		size = 33,
		total_codewords = 100,
		remainder_bits = 7,
		alignment_centers = {6, 26},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 80,
				ec_codewords = 20,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 100, k = 80, r = 10}},
			},
			Encoding {
				level = .M,
				data_codewords = 64,
				ec_codewords = 36,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 50, k = 32, r = 9}},
			},
			Encoding {
				level = .Q,
				data_codewords = 48,
				ec_codewords = 52,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 50, k = 24, r = 13}},
			},
			Encoding {
				level = .H,
				data_codewords = 36,
				ec_codewords = 64,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 25, k = 9, r = 8}},
			},
		},
	},
	Version_Data {
		id = 5,
		size = 37,
		total_codewords = 134,
		remainder_bits = 7,
		alignment_centers = {6, 30},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 108,
				ec_codewords = 26,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 134, k = 108, r = 13}},
			},
			Encoding {
				level = .M,
				data_codewords = 86,
				ec_codewords = 48,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 67, k = 43, r = 12}},
			},
			Encoding {
				level = .Q,
				data_codewords = 62,
				ec_codewords = 72,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 33, k = 15, r = 9},
					EC_Block{p = 0, no_blocks = 2, c = 34, k = 16, r = 9},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 46,
				ec_codewords = 88,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 33, k = 11, r = 11},
					EC_Block{p = 0, no_blocks = 2, c = 34, k = 12, r = 11},
				},
			},
		},
	},
	Version_Data {
		id = 6,
		size = 41,
		total_codewords = 172,
		remainder_bits = 7,
		alignment_centers = {6, 34},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 136,
				ec_codewords = 36,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 86, k = 68, r = 9}},
			},
			Encoding {
				level = .M,
				data_codewords = 108,
				ec_codewords = 64,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 43, k = 27, r = 8}},
			},
			Encoding {
				level = .Q,
				data_codewords = 76,
				ec_codewords = 96,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 43, k = 19, r = 12}},
			},
			Encoding {
				level = .H,
				data_codewords = 60,
				ec_codewords = 112,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 43, k = 15, r = 14}},
			},
		},
	},
	Version_Data {
		id = 7,
		size = 45,
		total_codewords = 196,
		remainder_bits = 0,
		alignment_centers = {6, 22, 38},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 156,
				ec_codewords = 40,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 98, k = 78, r = 10}},
			},
			Encoding {
				level = .M,
				data_codewords = 124,
				ec_codewords = 72,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 49, k = 31, r = 9}},
			},
			Encoding {
				level = .Q,
				data_codewords = 88,
				ec_codewords = 108,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 32, k = 14, r = 9},
					EC_Block{p = 0, no_blocks = 4, c = 33, k = 15, r = 9},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 66,
				ec_codewords = 130,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 39, k = 13, r = 13},
					EC_Block{p = 0, no_blocks = 1, c = 40, k = 14, r = 13},
				},
			},
		},
	},
	Version_Data {
		id = 8,
		size = 49,
		total_codewords = 242,
		remainder_bits = 0,
		alignment_centers = {6, 24, 42},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 194,
				ec_codewords = 48,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 121, k = 97, r = 12}},
			},
			Encoding {
				level = .M,
				data_codewords = 154,
				ec_codewords = 88,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 60, k = 38, r = 11}},
			},
			Encoding {
				level = .Q,
				data_codewords = 110,
				ec_codewords = 132,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 61, k = 39, r = 11}},
			},
			Encoding {
				level = .H,
				data_codewords = 86,
				ec_codewords = 156,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 40, k = 18, r = 11}},
			},
		},
	},
	Version_Data {
		id = 9,
		size = 53,
		total_codewords = 292,
		remainder_bits = 0,
		alignment_centers = {6, 26, 46},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 232,
				ec_codewords = 60,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 146, k = 116, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 182,
				ec_codewords = 110,
				blocks = {EC_Block{p = 0, no_blocks = 3, c = 58, k = 36, r = 11}},
			},
			Encoding {
				level = .Q,
				data_codewords = 132,
				ec_codewords = 160,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 59, k = 37, r = 11}},
			},
			Encoding {
				level = .H,
				data_codewords = 100,
				ec_codewords = 192,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 36, k = 16, r = 10}},
			},
		},
	},
	Version_Data {
		id = 10,
		size = 57,
		total_codewords = 346,
		remainder_bits = 0,
		alignment_centers = {6, 28, 50},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 274,
				ec_codewords = 72,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 86, k = 68, r = 9}},
			},
			Encoding {
				level = .M,
				data_codewords = 216,
				ec_codewords = 130,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 69, k = 43, r = 13},
					EC_Block{p = 0, no_blocks = 1, c = 70, k = 44, r = 13},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 154,
				ec_codewords = 192,
				blocks = {
					EC_Block{p = 0, no_blocks = 6, c = 43, k = 19, r = 12},
					EC_Block{p = 0, no_blocks = 2, c = 44, k = 20, r = 12},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 122,
				ec_codewords = 224,
				blocks = {
					EC_Block{p = 0, no_blocks = 6, c = 43, k = 15, r = 14},
					EC_Block{p = 0, no_blocks = 2, c = 44, k = 16, r = 14},
				},
			},
		},
	},
	Version_Data {
		id = 11,
		size = 61,
		total_codewords = 404,
		remainder_bits = 0,
		alignment_centers = {6, 30, 54},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 324,
				ec_codewords = 80,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 101, k = 81, r = 10}},
			},
			Encoding {
				level = .M,
				data_codewords = 254,
				ec_codewords = 150,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 80, k = 50, r = 15}},
			},
			Encoding {
				level = .Q,
				data_codewords = 180,
				ec_codewords = 224,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 81, k = 51, r = 15}},
			},
			Encoding {
				level = .H,
				data_codewords = 140,
				ec_codewords = 264,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 50, k = 22, r = 14}},
			},
		},
	},
	Version_Data {
		id = 12,
		size = 65,
		total_codewords = 466,
		remainder_bits = 0,
		alignment_centers = {6, 32, 58},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 370,
				ec_codewords = 96,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 116, k = 92, r = 12}},
			},
			Encoding {
				level = .M,
				data_codewords = 290,
				ec_codewords = 176,
				blocks = {
					EC_Block{p = 0, no_blocks = 6, c = 58, k = 36, r = 11},
					EC_Block{p = 0, no_blocks = 2, c = 59, k = 36, r = 11},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 206,
				ec_codewords = 260,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 46, k = 20, r = 13},
					EC_Block{p = 0, no_blocks = 6, c = 47, k = 21, r = 13},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 158,
				ec_codewords = 308,
				blocks = {
					EC_Block{p = 0, no_blocks = 7, c = 42, k = 14, r = 14},
					EC_Block{p = 0, no_blocks = 4, c = 43, k = 15, r = 14},
				},
			},
		},
	},
	Version_Data {
		id = 13,
		size = 69,
		total_codewords = 532,
		remainder_bits = 0,
		alignment_centers = {6, 34, 62},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 428,
				ec_codewords = 104,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 133, k = 107, r = 13}},
			},
			Encoding {
				level = .M,
				data_codewords = 334,
				ec_codewords = 198,
				blocks = {EC_Block{p = 0, no_blocks = 8, c = 59, k = 37, r = 11}},
			},
			Encoding {
				level = .Q,
				data_codewords = 244,
				ec_codewords = 288,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 60, k = 38, r = 11}},
			},
			Encoding {
				level = .H,
				data_codewords = 180,
				ec_codewords = 352,
				blocks = {EC_Block{p = 0, no_blocks = 8, c = 44, k = 20, r = 12}},
			},
		},
	},
	Version_Data {
		id = 14,
		size = 73,
		total_codewords = 581,
		remainder_bits = 3,
		alignment_centers = {6, 26, 46, 66},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 461,
				ec_codewords = 120,
				blocks = {EC_Block{p = 0, no_blocks = 3, c = 145, k = 115, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 365,
				ec_codewords = 216,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 64, k = 40, r = 12},
					EC_Block{p = 0, no_blocks = 5, c = 65, k = 41, r = 12},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 261,
				ec_codewords = 320,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 36, k = 16, r = 10},
					EC_Block{p = 0, no_blocks = 5, c = 37, k = 17, r = 10},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 197,
				ec_codewords = 384,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 36, k = 12, r = 12},
					EC_Block{p = 0, no_blocks = 5, c = 37, k = 13, r = 12},
				},
			},
		},
	},
	Version_Data {
		id = 15,
		size = 77,
		total_codewords = 655,
		remainder_bits = 3,
		alignment_centers = {6, 26, 48, 70},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 523,
				ec_codewords = 132,
				blocks = {EC_Block{p = 0, no_blocks = 5, c = 109, k = 75, r = 11}},
			},
			Encoding {
				level = .M,
				data_codewords = 415,
				ec_codewords = 240,
				blocks = {
					EC_Block{p = 0, no_blocks = 5, c = 65, k = 41, r = 12},
					EC_Block{p = 0, no_blocks = 5, c = 66, k = 42, r = 12},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 295,
				ec_codewords = 360,
				blocks = {
					EC_Block{p = 0, no_blocks = 5, c = 54, k = 24, r = 15},
					EC_Block{p = 0, no_blocks = 7, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 223,
				ec_codewords = 432,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 36, k = 12, r = 12},
					EC_Block{p = 0, no_blocks = 7, c = 37, k = 13, r = 12},
				},
			},
		},
	},
	Version_Data {
		id = 16,
		size = 81,
		total_codewords = 733,
		remainder_bits = 3,
		alignment_centers = {6, 26, 50, 74},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 589,
				ec_codewords = 144,
				blocks = {EC_Block{p = 0, no_blocks = 5, c = 122, k = 98, r = 12}},
			},
			Encoding {
				level = .M,
				data_codewords = 453,
				ec_codewords = 280,
				blocks = {
					EC_Block{p = 0, no_blocks = 7, c = 73, k = 45, r = 14},
					EC_Block{p = 0, no_blocks = 3, c = 74, k = 46, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 325,
				ec_codewords = 408,
				blocks = {
					EC_Block{p = 0, no_blocks = 15, c = 43, k = 19, r = 12},
					EC_Block{p = 0, no_blocks = 2, c = 44, k = 20, r = 12},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 253,
				ec_codewords = 480,
				blocks = {
					EC_Block{p = 0, no_blocks = 3, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 13, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 17,
		size = 85,
		total_codewords = 815,
		remainder_bits = 3,
		alignment_centers = {6, 30, 54, 78},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 647,
				ec_codewords = 168,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 135, k = 107, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 507,
				ec_codewords = 308,
				blocks = {
					EC_Block{p = 0, no_blocks = 10, c = 74, k = 46, r = 14},
					EC_Block{p = 0, no_blocks = 1, c = 75, k = 47, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 367,
				ec_codewords = 448,
				blocks = {
					EC_Block{p = 0, no_blocks = 1, c = 50, k = 22, r = 14},
					EC_Block{p = 0, no_blocks = 15, c = 51, k = 23, r = 14},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 283,
				ec_codewords = 532,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 42, k = 14, r = 14},
					EC_Block{p = 0, no_blocks = 17, c = 43, k = 15, r = 14},
				},
			},
		},
	},
	Version_Data {
		id = 18,
		size = 89,
		total_codewords = 901,
		remainder_bits = 3,
		alignment_centers = {6, 30, 56, 82},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 721,
				ec_codewords = 180,
				blocks = {EC_Block{p = 0, no_blocks = 5, c = 150, k = 120, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 563,
				ec_codewords = 338,
				blocks = {
					EC_Block{p = 0, no_blocks = 9, c = 69, k = 43, r = 13},
					EC_Block{p = 0, no_blocks = 4, c = 70, k = 44, r = 13},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 397,
				ec_codewords = 504,
				blocks = {
					EC_Block{p = 0, no_blocks = 17, c = 50, k = 22, r = 14},
					EC_Block{p = 0, no_blocks = 1, c = 51, k = 23, r = 14},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 313,
				ec_codewords = 588,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 42, k = 14, r = 14},
					EC_Block{p = 0, no_blocks = 19, c = 43, k = 15, r = 14},
				},
			},
		},
	},
	Version_Data {
		id = 19,
		size = 93,
		total_codewords = 991,
		remainder_bits = 3,
		alignment_centers = {6, 30, 58, 86},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 795,
				ec_codewords = 196,
				blocks = {EC_Block{p = 0, no_blocks = 3, c = 141, k = 113, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 627,
				ec_codewords = 364,
				blocks = {
					EC_Block{p = 0, no_blocks = 3, c = 70, k = 44, r = 13},
					EC_Block{p = 0, no_blocks = 11, c = 71, k = 45, r = 13},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 445,
				ec_codewords = 546,
				blocks = {
					EC_Block{p = 0, no_blocks = 17, c = 47, k = 21, r = 13},
					EC_Block{p = 0, no_blocks = 4, c = 48, k = 22, r = 13},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 341,
				ec_codewords = 650,
				blocks = {
					EC_Block{p = 0, no_blocks = 9, c = 39, k = 13, r = 13},
					EC_Block{p = 0, no_blocks = 16, c = 40, k = 14, r = 13},
				},
			},
		},
	},
	Version_Data {
		id = 20,
		size = 97,
		total_codewords = 1085,
		remainder_bits = 3,
		alignment_centers = {6, 34, 62, 90},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 861,
				ec_codewords = 224,
				blocks = {EC_Block{p = 0, no_blocks = 3, c = 135, k = 107, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 669,
				ec_codewords = 416,
				blocks = {
					EC_Block{p = 0, no_blocks = 3, c = 67, k = 41, r = 13},
					EC_Block{p = 0, no_blocks = 13, c = 68, k = 41, r = 13},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 485,
				ec_codewords = 600,
				blocks = {
					EC_Block{p = 0, no_blocks = 15, c = 54, k = 24, r = 15},
					EC_Block{p = 0, no_blocks = 5, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 385,
				ec_codewords = 700,
				blocks = {
					EC_Block{p = 0, no_blocks = 15, c = 43, k = 15, r = 14},
					EC_Block{p = 0, no_blocks = 10, c = 44, k = 16, r = 14},
				},
			},
		},
	},
	Version_Data {
		id = 21,
		size = 101,
		total_codewords = 1156,
		remainder_bits = 4,
		alignment_centers = {6, 28, 50, 72, 94},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 932,
				ec_codewords = 224,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 144, k = 116, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 714,
				ec_codewords = 442,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 145, k = 117, r = 14}},
			},
			Encoding {
				level = .Q,
				data_codewords = 512,
				ec_codewords = 644,
				blocks = {EC_Block{p = 0, no_blocks = 17, c = 68, k = 42, r = 13}},
			},
			Encoding {
				level = .H,
				data_codewords = 406,
				ec_codewords = 750,
				blocks = {EC_Block{p = 0, no_blocks = 17, c = 50, k = 22, r = 14}},
			},
		},
	},
	Version_Data {
		id = 22,
		size = 105,
		total_codewords = 1258,
		remainder_bits = 4,
		alignment_centers = {6, 26, 50, 74, 98},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1006,
				ec_codewords = 252,
				blocks = {EC_Block{p = 0, no_blocks = 2, c = 139, k = 111, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 782,
				ec_codewords = 476,
				blocks = {EC_Block{p = 0, no_blocks = 7, c = 140, k = 112, r = 14}},
			},
			Encoding {
				level = .Q,
				data_codewords = 568,
				ec_codewords = 690,
				blocks = {
					EC_Block{p = 0, no_blocks = 17, c = 74, k = 46, r = 14},
					EC_Block{p = 0, no_blocks = 7, c = 54, k = 24, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 442,
				ec_codewords = 816,
				blocks = {
					EC_Block{p = 0, no_blocks = 16, c = 55, k = 25, r = 15},
					EC_Block{p = 0, no_blocks = 34, c = 37, k = 13, r = 12},
				},
			},
		},
	},
	Version_Data {
		id = 23,
		size = 109,
		total_codewords = 1364,
		remainder_bits = 4,
		alignment_centers = {6, 30, 54, 78, 102},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1094,
				ec_codewords = 270,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 151, k = 121, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 860,
				ec_codewords = 504,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 75, k = 47, r = 14},
					EC_Block{p = 0, no_blocks = 14, c = 76, k = 48, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 614,
				ec_codewords = 750,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 54, k = 24, r = 15},
					EC_Block{p = 0, no_blocks = 14, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 464,
				ec_codewords = 900,
				blocks = {
					EC_Block{p = 0, no_blocks = 16, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 14, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 24,
		size = 113,
		total_codewords = 1474,
		remainder_bits = 4,
		alignment_centers = {6, 28, 54, 80, 106},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1174,
				ec_codewords = 300,
				blocks = {EC_Block{p = 0, no_blocks = 6, c = 147, k = 117, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 914,
				ec_codewords = 560,
				blocks = {
					EC_Block{p = 0, no_blocks = 6, c = 73, k = 45, r = 14},
					EC_Block{p = 0, no_blocks = 14, c = 74, k = 46, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 664,
				ec_codewords = 810,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 54, k = 24, r = 15},
					EC_Block{p = 0, no_blocks = 16, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 514,
				ec_codewords = 960,
				blocks = {
					EC_Block{p = 0, no_blocks = 30, c = 46, k = 16, r = 15},
					EC_Block{p = 0, no_blocks = 2, c = 47, k = 17, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 25,
		size = 117,
		total_codewords = 1588,
		remainder_bits = 4,
		alignment_centers = {6, 32, 58, 84, 110},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1276,
				ec_codewords = 312,
				blocks = {EC_Block{p = 0, no_blocks = 8, c = 132, k = 106, r = 13}},
			},
			Encoding {
				level = .M,
				data_codewords = 1000,
				ec_codewords = 588,
				blocks = {
					EC_Block{p = 0, no_blocks = 8, c = 75, k = 47, r = 14},
					EC_Block{p = 0, no_blocks = 13, c = 76, k = 48, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 718,
				ec_codewords = 870,
				blocks = {
					EC_Block{p = 0, no_blocks = 7, c = 54, k = 25, r = 15},
					EC_Block{p = 0, no_blocks = 22, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 538,
				ec_codewords = 1050,
				blocks = {
					EC_Block{p = 0, no_blocks = 22, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 13, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 26,
		size = 121,
		total_codewords = 1706,
		remainder_bits = 4,
		alignment_centers = {6, 30, 58, 86, 114},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1370,
				ec_codewords = 336,
				blocks = {EC_Block{p = 0, no_blocks = 10, c = 142, k = 114, r = 14}},
			},
			Encoding {
				level = .M,
				data_codewords = 1062,
				ec_codewords = 644,
				blocks = {
					EC_Block{p = 0, no_blocks = 19, c = 74, k = 46, r = 14},
					EC_Block{p = 0, no_blocks = 4, c = 75, k = 47, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 754,
				ec_codewords = 952,
				blocks = {
					EC_Block{p = 0, no_blocks = 28, c = 50, k = 22, r = 14},
					EC_Block{p = 0, no_blocks = 6, c = 51, k = 23, r = 14},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 596,
				ec_codewords = 1110,
				blocks = {
					EC_Block{p = 0, no_blocks = 33, c = 46, k = 16, r = 15},
					EC_Block{p = 0, no_blocks = 4, c = 47, k = 17, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 27,
		size = 125,
		total_codewords = 1828,
		remainder_bits = 4,
		alignment_centers = {6, 34, 62, 90, 118},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1468,
				ec_codewords = 360,
				blocks = {EC_Block{p = 0, no_blocks = 8, c = 152, k = 122, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 1128,
				ec_codewords = 700,
				blocks = {
					EC_Block{p = 0, no_blocks = 22, c = 73, k = 45, r = 14},
					EC_Block{p = 0, no_blocks = 3, c = 74, k = 46, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 808,
				ec_codewords = 1020,
				blocks = {
					EC_Block{p = 0, no_blocks = 8, c = 53, k = 23, r = 15},
					EC_Block{p = 0, no_blocks = 26, c = 54, k = 24, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 628,
				ec_codewords = 1200,
				blocks = {
					EC_Block{p = 0, no_blocks = 12, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 28, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 28,
		size = 129,
		total_codewords = 1921,
		remainder_bits = 3,
		alignment_centers = {6, 26, 50, 74, 98, 122},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1531,
				ec_codewords = 390,
				blocks = {EC_Block{p = 0, no_blocks = 3, c = 147, k = 117, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 1193,
				ec_codewords = 728,
				blocks = {
					EC_Block{p = 0, no_blocks = 3, c = 73, k = 45, r = 14},
					EC_Block{p = 0, no_blocks = 23, c = 74, k = 46, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 871,
				ec_codewords = 1050,
				blocks = {
					EC_Block{p = 0, no_blocks = 4, c = 54, k = 25, r = 15},
					EC_Block{p = 0, no_blocks = 31, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 661,
				ec_codewords = 1260,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 31, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 29,
		size = 133,
		total_codewords = 2051,
		remainder_bits = 3,
		alignment_centers = {6, 30, 54, 78, 102, 126},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1631,
				ec_codewords = 420,
				blocks = {EC_Block{p = 0, no_blocks = 7, c = 146, k = 116, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 1267,
				ec_codewords = 784,
				blocks = {
					EC_Block{p = 0, no_blocks = 21, c = 73, k = 45, r = 14},
					EC_Block{p = 0, no_blocks = 7, c = 74, k = 46, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 911,
				ec_codewords = 1140,
				blocks = {
					EC_Block{p = 0, no_blocks = 1, c = 53, k = 23, r = 15},
					EC_Block{p = 0, no_blocks = 37, c = 54, k = 24, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 701,
				ec_codewords = 1350,
				blocks = {
					EC_Block{p = 0, no_blocks = 19, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 26, c = 46, k = 16, r = 16},
				},
			},
		},
	},
	Version_Data {
		id = 30,
		size = 137,
		total_codewords = 2185,
		remainder_bits = 3,
		alignment_centers = {6, 26, 52, 78, 104, 130},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1735,
				ec_codewords = 450,
				blocks = {EC_Block{p = 0, no_blocks = 5, c = 145, k = 115, r = 15}},
			},
			Encoding {
				level = .M,
				data_codewords = 1373,
				ec_codewords = 812,
				blocks = {
					EC_Block{p = 0, no_blocks = 19, c = 75, k = 47, r = 14},
					EC_Block{p = 0, no_blocks = 10, c = 76, k = 48, r = 14},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 985,
				ec_codewords = 1200,
				blocks = {
					EC_Block{p = 0, no_blocks = 15, c = 54, k = 24, r = 15},
					EC_Block{p = 0, no_blocks = 25, c = 55, k = 25, r = 15},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 745,
				ec_codewords = 1440,
				blocks = {
					EC_Block{p = 0, no_blocks = 23, c = 45, k = 15, r = 15},
					EC_Block{p = 0, no_blocks = 25, c = 46, k = 16, r = 15},
				},
			},
		},
	},
	Version_Data {
		id = 31,
		size = 141,
		total_codewords = 2323,
		remainder_bits = 3,
		alignment_centers = {6, 30, 56, 82, 108, 134},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1843,
				ec_codewords = 480,
				blocks = {EC_Block{p = 0, no_blocks = 13, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1455,
				ec_codewords = 868,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 29, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1033,
				ec_codewords = 1290,
				blocks = {
					EC_Block{p = 0, no_blocks = 42, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 793,
				ec_codewords = 1530,
				blocks = {
					EC_Block{p = 0, no_blocks = 23, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 28, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 32,
		size = 145,
		total_codewords = 2465,
		remainder_bits = 3,
		alignment_centers = {6, 34, 60, 86, 112, 138},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 1955,
				ec_codewords = 510,
				blocks = {EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1541,
				ec_codewords = 924,
				blocks = {
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1115,
				ec_codewords = 1350,
				blocks = {
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 845,
				ec_codewords = 1620,
				blocks = {
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 33,
		size = 149,
		total_codewords = 2611,
		remainder_bits = 3,
		alignment_centers = {6, 30, 58, 86, 114, 142},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2071,
				ec_codewords = 540,
				blocks = {EC_Block{p = 0, no_blocks = 17, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1631,
				ec_codewords = 980,
				blocks = {
					EC_Block{p = 0, no_blocks = 14, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 21, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1171,
				ec_codewords = 1440,
				blocks = {
					EC_Block{p = 0, no_blocks = 29, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 19, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 901,
				ec_codewords = 1710,
				blocks = {
					EC_Block{p = 0, no_blocks = 11, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 46, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 34,
		size = 153,
		total_codewords = 2761,
		remainder_bits = 3,
		alignment_centers = {6, 34, 62, 90, 118, 146},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2191,
				ec_codewords = 570,
				blocks = {EC_Block{p = 0, no_blocks = 13, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1725,
				ec_codewords = 1036,
				blocks = {
					EC_Block{p = 0, no_blocks = 14, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 23, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1231,
				ec_codewords = 1530,
				blocks = {
					EC_Block{p = 0, no_blocks = 44, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 7, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 961,
				ec_codewords = 1800,
				blocks = {
					EC_Block{p = 0, no_blocks = 59, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 1, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 35,
		size = 157,
		total_codewords = 2876,
		remainder_bits = 0,
		alignment_centers = {6, 30, 54, 78, 102, 126, 150},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2306,
				ec_codewords = 570,
				blocks = {EC_Block{p = 0, no_blocks = 12, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1812,
				ec_codewords = 1064,
				blocks = {
					EC_Block{p = 0, no_blocks = 12, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 26, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1286,
				ec_codewords = 1590,
				blocks = {
					EC_Block{p = 0, no_blocks = 39, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 14, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 986,
				ec_codewords = 1890,
				blocks = {
					EC_Block{p = 0, no_blocks = 22, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 41, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 36,
		size = 161,
		total_codewords = 3034,
		remainder_bits = 0,
		alignment_centers = {6, 24, 50, 76, 102, 128, 154},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2434,
				ec_codewords = 600,
				blocks = {EC_Block{p = 0, no_blocks = 6, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1914,
				ec_codewords = 1120,
				blocks = {
					EC_Block{p = 0, no_blocks = 6, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 34, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1354,
				ec_codewords = 1680,
				blocks = {
					EC_Block{p = 0, no_blocks = 46, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 10, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 1054,
				ec_codewords = 1980,
				blocks = {
					EC_Block{p = 0, no_blocks = 2, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 64, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 37,
		size = 165,
		total_codewords = 3196,
		remainder_bits = 0,
		alignment_centers = {6, 28, 54, 80, 106, 132, 158},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2566,
				ec_codewords = 630,
				blocks = {EC_Block{p = 0, no_blocks = 17, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 1992,
				ec_codewords = 1204,
				blocks = {
					EC_Block{p = 0, no_blocks = 29, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 14, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1426,
				ec_codewords = 1770,
				blocks = {
					EC_Block{p = 0, no_blocks = 49, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 10, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 1096,
				ec_codewords = 2100,
				blocks = {
					EC_Block{p = 0, no_blocks = 24, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 46, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 38,
		size = 169,
		total_codewords = 3362,
		remainder_bits = 0,
		alignment_centers = {6, 32, 58, 84, 110, 136, 162},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2702,
				ec_codewords = 660,
				blocks = {EC_Block{p = 0, no_blocks = 4, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 2102,
				ec_codewords = 1260,
				blocks = {
					EC_Block{p = 0, no_blocks = 13, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 32, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1502,
				ec_codewords = 1860,
				blocks = {
					EC_Block{p = 0, no_blocks = 48, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 14, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 1142,
				ec_codewords = 2220,
				blocks = {
					EC_Block{p = 0, no_blocks = 42, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 32, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 39,
		size = 173,
		total_codewords = 3532,
		remainder_bits = 0,
		alignment_centers = {6, 26, 54, 82, 110, 138, 166},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2812,
				ec_codewords = 720,
				blocks = {EC_Block{p = 0, no_blocks = 20, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 2216,
				ec_codewords = 1316,
				blocks = {
					EC_Block{p = 0, no_blocks = 40, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 7, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1582,
				ec_codewords = 1950,
				blocks = {
					EC_Block{p = 0, no_blocks = 43, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 22, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 1222,
				ec_codewords = 2310,
				blocks = {
					EC_Block{p = 0, no_blocks = 10, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 67, c = 0, k = 0, r = 0},
				},
			},
		},
	},
	Version_Data {
		id = 40,
		size = 177,
		total_codewords = 3706,
		remainder_bits = 0,
		alignment_centers = {6, 30, 58, 86, 114, 142, 170},
		encodings = {
			Encoding {
				level = .L,
				data_codewords = 2956,
				ec_codewords = 750,
				blocks = {EC_Block{p = 0, no_blocks = 19, c = 0, k = 0, r = 0}},
			},
			Encoding {
				level = .M,
				data_codewords = 2334,
				ec_codewords = 1372,
				blocks = {
					EC_Block{p = 0, no_blocks = 18, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 31, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .Q,
				data_codewords = 1666,
				ec_codewords = 2040,
				blocks = {
					EC_Block{p = 0, no_blocks = 34, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 34, c = 0, k = 0, r = 0},
				},
			},
			Encoding {
				level = .H,
				data_codewords = 1276,
				ec_codewords = 2430,
				blocks = {
					EC_Block{p = 0, no_blocks = 20, c = 0, k = 0, r = 0},
					EC_Block{p = 0, no_blocks = 61, c = 0, k = 0, r = 0},
				},
			},
		},
	},
}
