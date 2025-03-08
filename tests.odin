package qrcode

import "core:fmt"
import "core:testing"

@(test)
segmenter :: proc(t: ^testing.T) {
	data := "Pa! &abc123 DEFGHIJ"
	segments := segment_data(transmute([]u8)data)
	testing.expect(t, len(segments) == 2, "Expected Two segments")
	testing.expect(t, segments[0].mode == .Byte, "Segment 1 as .Byte")
	testing.expect(t, segments[1].mode == .Alphanumeric, "Segment 1 as .Alphanumeric")
	delete(segments)

	data = "12345"
	segments = segment_data(transmute([]u8)data)
	testing.expect(t, len(segments) == 1, "Expected 1 segment")
	testing.expect(t, segments[0].mode == .Numeric, "Segment 1 as .Numeric")
	delete(segments)

	data = "ABC123"
	segments = segment_data(transmute([]u8)data)
	testing.expect(t, len(segments) == 1, "Expected 1 segment")
	testing.expect(t, segments[0].mode == .Alphanumeric, "Segment 1 as .Alphanumeric")
	delete(segments)

	data = "Hello, world!"
	segments = segment_data(transmute([]u8)data)
	testing.expect(t, len(segments) == 1, "Expected 1 segment")
	testing.expect(t, segments[0].mode == .Byte, "Segment 1 as .Byte")
	delete(segments)
}
