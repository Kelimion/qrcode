# QR-Code Generator

Basic Implementation of QRCode Spec to ISO 18004:2015, with the limitations listed in `Unsupported Features`.

Versions 1H and 4H have been tested. Any other version who knows.. (Very likely there are typos in the version_data table. It was manually trascribed)

## Unsupported Features

-   Micro Codes
-   Kanji
-   ECI
-   Reflectance Reversal
-   Mirror Orientation
-   C, K, R table-data is not populated on version 31-40; they wont work until it is filled
-   Decoding

## Reed-Solomon Encoding

This is a very basic implementation, and I'd say a low performance implementation.

## Useful Utilities

[QRazyBox](https://merri.cx/qrazybox/) - a nice tool for decoding a qr-code and seeing what it thinks the data is. Used extensively to compare against produced qrcodes to help zero-in on implementation errors.

[Thonky QRCode Tutorial](https://www.thonky.com/qr-code-tutorial/) - Excellent resource to supplement the ISO, which is not great at explaining itself.
