//
//   HTMLPurifier_Encoder.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


//    /** No bugs detected in iconv. */
#define ICONV_OK @"ICONV_OK"
//
//    /** Iconv truncates output if converting from UTF-8 to another
//     *  character set with //IGNORE, and a non-encodable character is found */
#define ICONV_TRUNCATES @"ICONV_TRUNCATES"
//
//    /** Iconv does not support //IGNORE, making it unusable for
//     *  transcoding purposes */
#define ICONV_UNUSABLE @"ICONV_USABLE"


#import "HTMLPurifier_Encoder.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_Encoder

/**
 * Constructor throws fatal error if you attempt to instantiate class
 */
- (id)init
{
    self = [super init];
    if (self) {
        TRIGGER_ERROR(@"Cannot instantiate encoder, call methods statically");
    }
    return self;
}

/**
 * Error-handler that mutes errors, alternative to shut-up operator.
 */
+ (void)muteErrorHandler
{
}

+ (NSString*)unichr:(int)code
{
    return [NSString stringWithFormat:@"%C", (unichar)code];
    /*
    if(code < 0 || (code >= 55296 && code <= 57343) || code > 1114111)
        return @"";

    //zero char doesn't work with format specifiers, for some reason...
    if(code ==0)
        return @"\0";

    NSInteger x = 0;
    NSInteger y = 0;
    NSInteger z = 0;
    NSInteger w = 0;

    if(code < 128)
    {
        x = code;
    }
    else
    {
        x = (code & 63) | 128;
        if(code < 2048)
        {
            y = ((code & 2047) >> 6) | 192;
        }
        else
        {
            y = ((code & 4032) >> 6) | 128;
            if(code < 65536)
            {
                z = ((code >> 12) & 15) | 224;
            }
            else
            {
                z = ((code >> 12) & 63) | 128;
                w = ((code >> 18) & 7) | 240;
            }
        }
    }

    // set up the actual character
    NSMutableString* ret = [NSMutableString new];
    if (w) {
        [ret appendFormat:@"%C", (unichar)(w)];
    }
    if (z) {
        [ret appendFormat:@"%C", (unichar)(z)];
    }
    if (y) {
        [ret appendFormat:@"%C", (unichar)(y)];
    }
    [ret appendFormat:@"%C", (unichar)(x)];

    return ret;*/
}



//return [NSString stringWithFormat:@"%C", (unichar)code];

//
//        $x = $y = $z = $w = 0;
//        if ($code < 128) {
//            // regular ASCII character
//            $x = $code;
//        } else {
//            // set up bits for UTF-8
//            $x = ($code & 63) | 128;
//            if ($code < 2048) {
//                $y = (($code & 2047) >> 6) | 192;
//            } else {
//                $y = (($code & 4032) >> 6) | 128;
//                if ($code < 65536) {
//                    $z = (($code >> 12) & 15) | 224;
//                } else {
//                    $z = (($code >> 12) & 63) | 128;
//                    $w = (($code >> 18) & 7)  | 240;
//                }
//            }
//        }
//        // set up the actual character
//        $ret = '';
//        if ($w) {
//            $ret .= chr($w);
//        }
//        if ($z) {
//            $ret .= chr($z);
//        }
//        if ($y) {
//            $ret .= chr($y);
//        }
//        $ret .= chr($x);
//
//        return $ret;
//    }}

/**
 * iconv wrapper which mutes errors, but doesn't work around bugs.
 * @param string $in Input encoding
 * @param string $out Output encoding
 * @param string $text The text to convert
 * @return string
 */
+ (NSString*)unsafeIconvWithIn:(NSObject*)in out:(NSObject*)out text:(NSObject*)text
{
    return nil;
    /*
     set_error_handler(array('HTMLPurifier_Encoder', 'muteErrorHandler'));
     NSString* r = iconv(in, out, text);
     restore_error_handler();
     return r;
     */
}

/**
 * iconv wrapper which mutes errors and works around bugs.
 * @param string $in Input encoding
 * @param string $out Output encoding
 * @param string $text The text to convert
 * @param int $max_chunk_size
 * @return string
 */
+ (NSString*)iconvWithIn:(NSString*)inputEncoding out:(NSString*)outputEncoding text:(NSString*)text;
{
    return [self iconvWithIn:inputEncoding out:outputEncoding text:text maxChunkSize:8000];
}

+ (NSString*)cleanUTF8:(NSString*)str
{
    if(!str)
        return nil;
    
    if (preg_match_2(@"^[\\x{9}\\x{A}\\x{D}\\x{20}-\\x{7E}\\x{A0}-\\x{D7FF}\\x{E000}-\\x{FFFD}\\x{10000}-\\x{10FFFF}]*$",
                   str
                   ))
        return str;

    NSData* UTF8Data = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

    
    NSString* cleanedUTF8String = [[NSString alloc] initWithData:UTF8Data encoding:NSUTF8StringEncoding];

    return cleanedUTF8String;


//    NSInteger mState = 0; // cached expected number of octets after the current octet
//                 // until the beginning of the next UTF8 character sequence
//    NSInteger mUcs4  = 0; // cached Unicode character
//    NSInteger mBytes = 1; // cached expected number of octets in the current sequence
//
//    // original code involved an $out that was an array of Unicode
//    // codepoints.  Instead of having to convert back into UTF-8, we've
//    // decided to directly append valid UTF-8 characters onto a string
//    // $out once they're done.  $char accumulates raw bytes, while $mUcs4
//    // turns into the Unicode code point, so there's some redundancy.
//
//    NSMutableString* outString = [@"" mutableCopy];
//    NSMutableString* charString = [@"" mutableCopy];
//
//    NSInteger len = str.length;
//    for (NSInteger i = 0; i < len; i++)
//    {
//        int inChar = [str characterAtIndex:i];
//        [charString appendString:[str substringWithRange:NSMakeRange(i,1)]]; // append byte to char
//        if (0 == mState) {
//            // When mState is zero we expect either a US-ASCII character
//            // or a multi-octet sequence.
//            if (0 == (0x80 & (inChar)))
//            {
//                // US-ASCII, pass straight through.
//                if ((inChar <= 31 || inChar == 127) &&
//                    !(inChar == 9 || inChar == 13 || inChar == 10) // save \r\t\n
//                    ) {
//                    // control characters, remove
//                } else {
//                    [outString appendString:charString];
//                }
//                // reset
//                charString = [@"" mutableCopy];
//                mBytes = 1;
//            } else if (0xC0 == (0xE0 & (inChar)))
//            {
//                // First octet of 2 octet sequence
//                int mUcs4 = (inChar);
//                mUcs4 = (mUcs4 & 0x1F) << 6;
//                mState = 1;
//                mBytes = 2;
//            } else if (0xE0 == (0xF0 & (inChar)))
//            {
//                // First octet of 3 octet sequence
//                int mUcs4 = (inChar);
//                mUcs4 = (mUcs4 & 0x0F) << 12;
//                mState = 2;
//                mBytes = 3;
//            } else if (0xF0 == (0xF8 & (inChar)))
//            {
//                // First octet of 4 octet sequence
//                int mUcs4 = (inChar);
//                mUcs4 = (mUcs4 & 0x07) << 18;
//                mState = 3;
//                mBytes = 4;
//            } else if (0xF8 == (0xFC & (inChar))) {
//                // First octet of 5 octet sequence.
//                //
//                // This is illegal because the encoded codepoint must be
//                // either:
//                // (a) not the shortest form or
//                // (b) outside the Unicode range of 0-0x10FFFF.
//                // Rather than trying to resynchronize, we will carry on
//                // until the end of the sequence and let the later error
//                // handling code catch it.
//                int mUcs4 = (inChar);
//                mUcs4 = (mUcs4 & 0x03) << 24;
//                mState = 4;
//                mBytes = 5;
//            } else if (0xFC == (0xFE & (inChar))) {
//                // First octet of 6 octet sequence, see comments for 5
//                // octet sequence.
//                int mUcs4 = (inChar);
//                mUcs4 = (mUcs4 & 1) << 30;
//                mState = 5;
//                mBytes = 6;
//            } else {
//                // Current octet is neither in the US-ASCII range nor a
//                // legal first octet of a multi-octet sequence.
//                mState = 0;
//                mUcs4  = 0;
//                mBytes = 1;
//                charString = [@"" mutableCopy];
//            }
//        } else {
//            // When mState is non-zero, we expect a continuation of the
//            // multi-octet sequence
//            if (0x80 == (0xC0 & (inChar))) {
//                // Legal continuation.
//                NSInteger shift = (mState - 1) * 6;
//                int tmp = inChar;
//                tmp = (tmp & 0x0000003F) << shift;
//                mUcs4 |= tmp;
//
//                if (0 == --mState) {
//                    // End of the multi-octet sequence. mUcs4 now contains
//                    // the final Unicode codepoint to be output
//
//                    // Check for illegal sequences and codepoints.
//
//                    // From Unicode 3.1, non-shortest form is illegal
//                    if (((2 == mBytes) && (mUcs4 < 0x0080)) ||
//                        ((3 == mBytes) && (mUcs4 < 0x0800)) ||
//                        ((4 == mBytes) && (mUcs4 < 0x10000)) ||
//                        (4 < mBytes) ||
//                        // From Unicode 3.2, surrogate characters = illegal
//                        ((mUcs4 & 0xFFFFF800) == 0xD800) ||
//                        // Codepoints outside the Unicode range are illegal
//                        (mUcs4 > 0x10FFFF)
//                        ) {
//
//                    } else if (0xFEFF != mUcs4 && // omit BOM
//                              // check for valid Char unicode codepoints
//                              (
//                               0x9 == mUcs4 ||
//                               0xA == mUcs4 ||
//                               0xD == mUcs4 ||
//                               (0x20 <= mUcs4 && 0x7E >= mUcs4) ||
//                               // 7F-9F is not strictly prohibited by XML,
//                               // but it is non-SGML, and thus we don't allow it
//                               (0xA0 <= mUcs4 && 0xD7FF >= mUcs4) ||
//                               (0x10000 <= mUcs4 && 0x10FFFF >= mUcs4)
//                               )
//                              ) {
//                        [outString appendString:charString];
//                    }
//                    // initialize UTF8 cache (reset)
//                    mState = 0;
//                    mUcs4  = 0;
//                    mBytes = 1;
//                    charString = [@"" mutableCopy];
//                }
//            } else {
//                // ((0xC0 & (*in) != 0x80) && (mState != 0))
//                // Incomplete multi-octet sequence.
//                // used to result in complete fail, but we'll reset
//                mState = 0;
//                mUcs4  = 0;
//                mBytes = 1;
//                charString = [@"" mutableCopy];
//            }
//        }
//    }
//    return outString;
}

+ (NSString*)cleanUTF8:(NSString*)str forcePHP:force_php
{
    return [self cleanUTF8:str];
}

+ (NSString*)iconvWithIn:(NSString*)inputEncoding out:(NSString*)outputEncoding text:(NSString*)text maxChunkSize:(NSInteger)max_chunk_size
{
    return nil;
    /*
     NSString* code = [HTMLPurifier_Encoder testIconvTruncateBug];
     if ([code isEqualTo:ICONV_OK])
     {
     return [self unsafeIconvWithIn:inputEncoding out:outputEncoding text:text];
     } else if ([code isEqualTo:ICONV_TRUNCATES]) {
     // we can only work around this if the input character set
     // is utf-8
     if ([inputEncoding isEqualTo:@"utf-8"]) {
     if (max_chunk_size < 4) {
     TRIGGER_ERROR(@"max_chunk_size is too small");
     return nil;
     }
     // split into 8000 byte chunks, but be careful to handle
     // multibyte boundaries properly
     NSInteger c = text.length;
     if (c <= maxChunkSize)
     {
     return [self unsafeIconvWithIn:inputEncoding out:outputEncoding text:text];
     }
     NSMutableString* r = [NSMutableString new];
     NSInteger i = 0;
     while (true) {
     if (i + max_chunk_size >= c) {
     [r appendString:[self unsafeIconvWithIn:inputEncoding out:outputEncoding text:text]];                        break;
     }
     // wibble the boundary
     if (0x80 != (0xC0 & ord($text[$i + max_chunk_size]))) {
     chunk_size = max_chunk_size;
     } else if (0x80 != (0xC0 & ord($text[$i + $max_chunk_size - 1]))) {
     chunk_size = $max_chunk_size - 1;
     } else if (0x80 != (0xC0 & ord($text[$i + $max_chunk_size - 2]))) {
     chunk_size = $max_chunk_size - 2;
     } else if (0x80 != (0xC0 & ord($text[$i + $max_chunk_size - 3]))) {
     chunk_size = $max_chunk_size - 3;
     } else {
     return false; // rather confusing UTF-8...
     }
     $chunk = substr($text, $i, $chunk_size); // substr doesn't mind overlong lengths
     $r .= self::unsafeIconv($in, $out, $chunk);
     $i += $chunk_size;
     }
     return $r;
     } else {
     return false;
     }
     } else {
     return false;
     }*/
}

//    /**
//     * Cleans a UTF-8 string for well-formedness and SGML validity
//     *
//     * It will parse according to UTF-8 and return a valid UTF8 string, with
//     * non-SGML codepoints excluded.
//     *
//     * @param string $str The string to clean
//     * @param bool $force_php
//     * @return string
//     *
//     * @note Just for reference, the non-SGML code points are 0 to 31 and
//     *       127 to 159, inclusive.  However, we allow code points 9, 10
//     *       and 13, which are the tab, line feed and carriage return
//     *       respectively. 128 and above the code points map to multibyte
//     *       UTF-8 representations.
//     *
//     * @note Fallback code adapted from utf8ToUnicode by Henri Sivonen and
//     *       hsivonen@iki.fi at <http://iki.fi/hsivonen/php-utf8/> under the
//     *       LGPL license.  Notes on what changed are inside, but in general,
//     *       the original code transformed UTF-8 text into an array of integer
//     *       Unicode codepoints. Understandably, transforming that back to
//     *       a string would be somewhat expensive, so the function was modded to
//     *       directly operate on the string.  However, this discourages code
//     *       reuse, and the logic enumerated here would be useful for any
//     *       function that needs to be able to understand UTF-8 characters.
//     *       As of right now, only smart lossless character encoding converters
//     *       would need that, and I'm probably not going to implement them.
//     *       Once again, PHP 6 should solve all our problems.
//     */
//    public static function cleanUTF8($str, $force_php = false)
//    {
//        // UTF-8 validity is checked since PHP 4.3.5
//        // This is an optimization: if the string is already valid UTF-8, no
//        // need to do PHP stuff. 99% of the time, this will be the case.
//        // The regexp matches the XML char production, as well as well as excluding
//        // non-SGML codepoints U+007F to U+009F
//        if (preg_match(
//                       '/^[\x{9}\x{A}\x{D}\x{20}-\x{7E}\x{A0}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]*$/Du',
//                       $str
//                       )) {
//            return $str;
//        }
//
//        $mState = 0; // cached expected number of octets after the current octet
//                     // until the beginning of the next UTF8 character sequence
//        $mUcs4  = 0; // cached Unicode character
//        $mBytes = 1; // cached expected number of octets in the current sequence
//
//        // original code involved an $out that was an array of Unicode
//        // codepoints.  Instead of having to convert back into UTF-8, we've
//        // decided to directly append valid UTF-8 characters onto a string
//        // $out once they're done.  $char accumulates raw bytes, while $mUcs4
//        // turns into the Unicode code point, so there's some redundancy.
//
//        $out = '';
//        $char = '';
//
//        $len = strlen($str);
//        for ($i = 0; $i < $len; $i++) {
//            $in = ord($str{$i});
//            $char .= $str[$i]; // append byte to char
//            if (0 == $mState) {
//                // When mState is zero we expect either a US-ASCII character
//                // or a multi-octet sequence.
//                if (0 == (0x80 & ($in))) {
//                    // US-ASCII, pass straight through.
//                    if (($in <= 31 || $in == 127) &&
//                        !($in == 9 || $in == 13 || $in == 10) // save \r\t\n
//                        ) {
//                        // control characters, remove
//                    } else {
//                        $out .= $char;
//                    }
//                    // reset
//                    $char = '';
//                    $mBytes = 1;
//                } elseif (0xC0 == (0xE0 & ($in))) {
//                    // First octet of 2 octet sequence
//                    $mUcs4 = ($in);
//                    $mUcs4 = ($mUcs4 & 0x1F) << 6;
//                    $mState = 1;
//                    $mBytes = 2;
//                } elseif (0xE0 == (0xF0 & ($in))) {
//                    // First octet of 3 octet sequence
//                    $mUcs4 = ($in);
//                    $mUcs4 = ($mUcs4 & 0x0F) << 12;
//                    $mState = 2;
//                    $mBytes = 3;
//                } elseif (0xF0 == (0xF8 & ($in))) {
//                    // First octet of 4 octet sequence
//                    $mUcs4 = ($in);
//                    $mUcs4 = ($mUcs4 & 0x07) << 18;
//                    $mState = 3;
//                    $mBytes = 4;
//                } elseif (0xF8 == (0xFC & ($in))) {
//                    // First octet of 5 octet sequence.
//                    //
//                    // This is illegal because the encoded codepoint must be
//                    // either:
//                    // (a) not the shortest form or
//                    // (b) outside the Unicode range of 0-0x10FFFF.
//                    // Rather than trying to resynchronize, we will carry on
//                    // until the end of the sequence and let the later error
//                    // handling code catch it.
//                    $mUcs4 = ($in);
//                    $mUcs4 = ($mUcs4 & 0x03) << 24;
//                    $mState = 4;
//                    $mBytes = 5;
//                } elseif (0xFC == (0xFE & ($in))) {
//                    // First octet of 6 octet sequence, see comments for 5
//                    // octet sequence.
//                    $mUcs4 = ($in);
//                    $mUcs4 = ($mUcs4 & 1) << 30;
//                    $mState = 5;
//                    $mBytes = 6;
//                } else {
//                    // Current octet is neither in the US-ASCII range nor a
//                    // legal first octet of a multi-octet sequence.
//                    $mState = 0;
//                    $mUcs4  = 0;
//                    $mBytes = 1;
//                    $char = '';
//                }
//            } else {
//                // When mState is non-zero, we expect a continuation of the
//                // multi-octet sequence
//                if (0x80 == (0xC0 & ($in))) {
//                    // Legal continuation.
//                    $shift = ($mState - 1) * 6;
//                    $tmp = $in;
//                    $tmp = ($tmp & 0x0000003F) << $shift;
//                    $mUcs4 |= $tmp;
//
//                    if (0 == --$mState) {
//                        // End of the multi-octet sequence. mUcs4 now contains
//                        // the final Unicode codepoint to be output
//
//                        // Check for illegal sequences and codepoints.
//
//                        // From Unicode 3.1, non-shortest form is illegal
//                        if (((2 == $mBytes) && ($mUcs4 < 0x0080)) ||
//                            ((3 == $mBytes) && ($mUcs4 < 0x0800)) ||
//                            ((4 == $mBytes) && ($mUcs4 < 0x10000)) ||
//                            (4 < $mBytes) ||
//                            // From Unicode 3.2, surrogate characters = illegal
//                            (($mUcs4 & 0xFFFFF800) == 0xD800) ||
//                            // Codepoints outside the Unicode range are illegal
//                            ($mUcs4 > 0x10FFFF)
//                            ) {
//
//                        } elseif (0xFEFF != $mUcs4 && // omit BOM
//                                  // check for valid Char unicode codepoints
//                                  (
//                                   0x9 == $mUcs4 ||
//                                   0xA == $mUcs4 ||
//                                   0xD == $mUcs4 ||
//                                   (0x20 <= $mUcs4 && 0x7E >= $mUcs4) ||
//                                   // 7F-9F is not strictly prohibited by XML,
//                                   // but it is non-SGML, and thus we don't allow it
//                                   (0xA0 <= $mUcs4 && 0xD7FF >= $mUcs4) ||
//                                   (0x10000 <= $mUcs4 && 0x10FFFF >= $mUcs4)
//                                   )
//                                  ) {
//                            $out .= $char;
//                        }
//                        // initialize UTF8 cache (reset)
//                        $mState = 0;
//                        $mUcs4  = 0;
//                        $mBytes = 1;
//                        $char = '';
//                    }
//                } else {
//                    // ((0xC0 & (*in) != 0x80) && (mState != 0))
//                    // Incomplete multi-octet sequence.
//                    // used to result in complete fail, but we'll reset
//                    $mState = 0;
//                    $mUcs4  = 0;
//                    $mBytes = 1;
//                    $char ='';
//                }
//            }
//        }
//        return $out;
//    }
//
//    /**
//     * Translates a Unicode codepoint into its corresponding UTF-8 character.
//     * @note Based on Feyd's function at
//     *       <http://forums.devnetwork.net/viewtopic.php?p=191404#191404>,
//     *       which is in public domain.
//     * @note While we're going to do code point parsing anyway, a good
//     *       optimization would be to refuse to translate code points that
//     *       are non-SGML characters.  However, this could lead to duplication.
//     * @note This is very similar to the unichr function in
//     *       maintenance/generate-entity-file.php (although this is superior,
//     *       due to its sanity checks).
//     */
//
//    // +----------+----------+----------+----------+
//    // | 33222222 | 22221111 | 111111   |          |
//    // | 10987654 | 32109876 | 54321098 | 76543210 | bit
//    // +----------+----------+----------+----------+
//    // |          |          |          | 0xxxxxxx | 1 byte 0x00000000..0x0000007F
//    // |          |          | 110yyyyy | 10xxxxxx | 2 byte 0x00000080..0x000007FF
//    // |          | 1110zzzz | 10yyyyyy | 10xxxxxx | 3 byte 0x00000800..0x0000FFFF
//    // | 11110www | 10wwzzzz | 10yyyyyy | 10xxxxxx | 4 byte 0x00010000..0x0010FFFF
//    // +----------+----------+----------+----------+
//    // | 00000000 | 00011111 | 11111111 | 11111111 | Theoretical upper limit of legal scalars: 2097151 (0x001FFFFF)
//    // | 00000000 | 00010000 | 11111111 | 11111111 | Defined upper limit of legal scalar codes
//    // +----------+----------+----------+----------+
//
//    public static function unichr($code)
//    {
//        if ($code > 1114111 or $code < 0 or
//            ($code >= 55296 and $code <= 57343) ) {
//            // bits are set outside the "valid" range as defined
//            // by UNICODE 4.1.0
//            return '';
//        }
//
//        $x = $y = $z = $w = 0;
//        if ($code < 128) {
//            // regular ASCII character
//            $x = $code;
//        } else {
//            // set up bits for UTF-8
//            $x = ($code & 63) | 128;
//            if ($code < 2048) {
//                $y = (($code & 2047) >> 6) | 192;
//            } else {
//                $y = (($code & 4032) >> 6) | 128;
//                if ($code < 65536) {
//                    $z = (($code >> 12) & 15) | 224;
//                } else {
//                    $z = (($code >> 12) & 63) | 128;
//                    $w = (($code >> 18) & 7)  | 240;
//                }
//            }
//        }
//        // set up the actual character
//        $ret = '';
//        if ($w) {
//            $ret .= chr($w);
//        }
//        if ($z) {
//            $ret .= chr($z);
//        }
//        if ($y) {
//            $ret .= chr($y);
//        }
//        $ret .= chr($x);
//
//        return $ret;
//    }
//
//    /**
//     * @return bool
//     */
//    public static function iconvAvailable()
//    {
//        static $iconv = null;
//        if ($iconv === null) {
//            $iconv = function_exists('iconv') && self::testIconvTruncateBug() != self::ICONV_UNUSABLE;
//        }
//        return $iconv;
//    }
//
//    /**
//     * Convert a string to UTF-8 based on configuration.
//     * @param string $str The string to convert
//     * @param HTMLPurifier_Config $config
//     * @param HTMLPurifier_Context $context
//     * @return string
//     */
+ (NSString*)convertToUTF8:(NSString*)str config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSNumber* encoding = (NSNumber*)[config get:@"Core.Encoding"];
    if (encoding.integerValue == NSUTF8StringEncoding)
    {
        return str;
    }
    NSData* rawData = [str dataUsingEncoding:encoding.integerValue];
    NSString* utf8String = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    return utf8String;
}
//        static $iconv = null;
//        if ($iconv === null) {
//            $iconv = self::iconvAvailable();
//        }
//        if ($iconv && !$config->get('Test.ForceNoIconv')) {
//            // unaffected by bugs, since UTF-8 support all characters
//            $str = self::unsafeIconv($encoding, 'utf-8//IGNORE', $str);
//            if ($str === false) {
//                // $encoding is not a valid encoding
//                trigger_error('Invalid encoding ' . $encoding, E_USER_ERROR);
//                return '';
//            }
//            // If the string is bjorked by Shift_JIS or a similar encoding
//            // that doesn't support all of ASCII, convert the naughty
//            // characters to their true byte-wise ASCII/UTF-8 equivalents.
//            $str = strtr($str, self::testEncodingSupportsASCII($encoding));
//            return $str;
//        } elseif ($encoding === 'iso-8859-1') {
//            $str = utf8_encode($str);
//            return $str;
//        }
//        $bug = HTMLPurifier_Encoder::testIconvTruncateBug();
//        if ($bug == self::ICONV_OK) {
//            trigger_error('Encoding not supported, please install iconv', E_USER_ERROR);
//        } else {
//            trigger_error(
//                          'You have a buggy version of iconv, see https://bugs.php.net/bug.php?id=48147 ' .
//                          'and http://sourceware.org/bugzilla/show_bug.cgi?id=13541',
//                          E_USER_ERROR
//                          );
//        }
//    }
//
//    /**
//     * Converts a string from UTF-8 based on configuration.
//     * @param string $str The string to convert
//     * @param HTMLPurifier_Config $config
//     * @param HTMLPurifier_Context $context
//     * @return string
//     * @note Currently, this is a lossy conversion, with unexpressable
//     *       characters being omitted.
//     */
+ (NSString*)convertFromUTF8:(NSString*)passedStr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSString* str = passedStr;
    NSNumber* encoding = (NSNumber*)[config get:@"Core.Encoding"];
    NSNumber* escape = (NSNumber*)[config get:@"Core.EscapeNonASCIICharacters"];

    if (encoding.integerValue == NSUTF8StringEncoding && !escape.boolValue)
    {
        return str;
    }

    NSData* stringData = [str dataUsingEncoding:NSUTF8StringEncoding];

    if(escape.boolValue)
    {
        stringData = [self convertToASCIIDumbLossless:stringData];
    }

    NSString* newString = [[NSString alloc] initWithData:stringData encoding:encoding.integerValue];

    return newString;
}
//    {
//        $encoding = $config->get('Core.Encoding');
//        if ($escape = $config->get('Core.EscapeNonASCIICharacters')) {
//            $str = self::convertToASCIIDumbLossless($str);
//        }
//        if ($encoding === 'utf-8') {
//            return $str;
//        }
//        static $iconv = null;
//        if ($iconv === null) {
//            $iconv = self::iconvAvailable();
//        }
//        if ($iconv && !$config->get('Test.ForceNoIconv')) {
//            // Undo our previous fix in convertToUTF8, otherwise iconv will barf
//            $ascii_fix = self::testEncodingSupportsASCII($encoding);
//            if (!$escape && !empty($ascii_fix)) {
//                $clear_fix = array();
//                foreach ($ascii_fix as $utf8 => $native) {
//                    $clear_fix[$utf8] = '';
//                }
//                $str = strtr($str, $clear_fix);
//            }
//            $str = strtr($str, array_flip($ascii_fix));
//            // Normal stuff
//            $str = self::iconv('utf-8', $encoding . '//IGNORE', $str);
//            return $str;
//        } elseif ($encoding === 'iso-8859-1') {
//            $str = utf8_decode($str);
//            return $str;
//        }
//        trigger_error('Encoding not supported', E_USER_ERROR);
//        // You might be tempted to assume that the ASCII representation
//        // might be OK, however, this is *not* universally true over all
//        // encodings.  So we take the conservative route here, rather
//        // than forcibly turn on %Core.EscapeNonASCIICharacters
//    }
//
//    /**
//     * Lossless (character-wise) conversion of HTML to ASCII
//     * @param string $str UTF-8 string to be converted to ASCII
//     * @return string ASCII encoded string with non-ASCII character entity-ized
//     * @warning Adapted from MediaWiki, claiming fair use: this is a common
//     *       algorithm. If you disagree with this license fudgery,
//     *       implement it yourself.
//     * @note Uses decimal numeric entities since they are best supported.
//     * @note This is a DUMB function: it has no concept of keeping
//     *       character entities that the projected character encoding
//     *       can allow. We could possibly implement a smart version
//     *       but that would require it to also know which Unicode
//     *       codepoints the charset supported (not an easy task).
//     * @note Sort of with cleanUTF8() but it assumes that $str is
//     *       well-formed UTF-8
//     */
+ (NSData*)convertToASCIIDumbLossless:(NSData*)data
{
        NSInteger bytesleft = 0;
        NSMutableData* result = [NSMutableData new];
        int working = 0;
        NSInteger len = data.length;
        const unsigned char* dataBytes = data.bytes;
        for (NSInteger i = 0; i < len; i++)
        {
            unsigned char bytevalue = dataBytes[i];
            if (bytevalue <= 0x7F) { //0xxx xxxx
                [result appendBytes:&bytevalue length:1];
                 //String:[NSString stringWithCharacters:(unichar*)&bytevalue length:1]];
                bytesleft = 0;
            } else if (bytevalue <= 0xBF) { //10xx xxxx
                working = working << 6;
                working += (bytevalue & 0x3F);
                bytesleft--;
                if (bytesleft <= 0) {
                    NSString* string = [NSString stringWithFormat:@"&#%d;", working];
                    [result appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
                     //appendFormat:@"&#%d;", working];
                }
            } else if (bytevalue <= 0xDF) { //110x xxxx
                working = bytevalue & 0x1F;
                bytesleft = 1;
            } else if (bytevalue <= 0xEF) { //1110 xxxx
                working = bytevalue & 0x0F;
                bytesleft = 2;
            } else { //1111 0xxx
                working = bytevalue & 0x07;
                bytesleft = 3;
            }
        }
        return result;
    }


//
//    /**
//     * glibc iconv has a known bug where it doesn't handle the magic
//     * //IGNORE stanza correctly.  In particular, rather than ignore
//     * characters, it will return an EILSEQ after consuming some number
//     * of characters, and expect you to restart iconv as if it were
//     * an E2BIG.  Old versions of PHP did not respect the errno, and
//     * returned the fragment, so as a result you would see iconv
//     * mysteriously truncating output. We can work around this by
//     * manually chopping our input into segments of about 8000
//     * characters, as long as PHP ignores the error code.  If PHP starts
//     * paying attention to the error code, iconv becomes unusable.
//     *
//     * @return int Error code indicating severity of bug.
//     */
+ (NSString*)testIconvTruncateBug
{
    return nil;
}
//    {
//        static $code = null;
//        if ($code === null) {
//            // better not use iconv, otherwise infinite loop!
//            $r = self::unsafeIconv('utf-8', 'ascii//IGNORE', "\xCE\xB1" . str_repeat('a', 9000));
//            if ($r === false) {
//                $code = self::ICONV_UNUSABLE;
//            } elseif (($c = strlen($r)) < 9000) {
//                $code = self::ICONV_TRUNCATES;
//            } elseif ($c > 9000) {
//                trigger_error(
//                              'Your copy of iconv is extremely buggy. Please notify HTML Purifier maintainers: ' .
//                              'include your iconv version as per phpversion()',
//                              E_USER_ERROR
//                              );
//            } else {
//                $code = self::ICONV_OK;
//            }
//        }
//        return $code;
//    }
//
//    /**
//     * This expensive function tests whether or not a given character
//     * encoding supports ASCII. 7/8-bit encodings like Shift_JIS will
//     * fail this test, and require special processing. Variable width
//     * encodings shouldn't ever fail.
//     *
//     * @param string $encoding Encoding name to test, as per iconv format
//     * @param bool $bypass Whether or not to bypass the precompiled arrays.
//     * @return Array of UTF-8 characters to their corresponding ASCII,
//     *      which can be used to "undo" any overzealous iconv action.
//     */
//    public static function testEncodingSupportsASCII($encoding, $bypass = false)
//    {
//        // All calls to iconv here are unsafe, proof by case analysis:
//        // If ICONV_OK, no difference.
//        // If ICONV_TRUNCATE, all calls involve one character inputs,
//        // so bug is not triggered.
//        // If ICONV_UNUSABLE, this call is irrelevant
//        static $encodings = array();
//        if (!$bypass) {
//            if (isset($encodings[$encoding])) {
//                return $encodings[$encoding];
//            }
//            $lenc = strtolower($encoding);
//            switch ($lenc) {
//                case 'shift_jis':
//                    return array("\xC2\xA5" => '\\', "\xE2\x80\xBE" => '~');
//                case 'johab':
//                    return array("\xE2\x82\xA9" => '\\');
//            }
//            if (strpos($lenc, 'iso-8859-') === 0) {
//                return array();
//            }
//        }
//        $ret = array();
//        if (self::unsafeIconv('UTF-8', $encoding, 'a') === false) {
//            return false;
//        }
//        for ($i = 0x20; $i <= 0x7E; $i++) { // all printable ASCII chars
//            $c = chr($i); // UTF-8 char
//            $r = self::unsafeIconv('UTF-8', "$encoding//IGNORE", $c); // initial conversion
//            if ($r === '' ||
//                // This line is needed for iconv implementations that do not
//                // omit characters that do not exist in the target character set
//                ($r === $c && self::unsafeIconv($encoding, 'UTF-8//IGNORE', $r) !== $c)
//                ) {
//                // Reverse engineer: what's the UTF-8 equiv of this byte
//                // sequence? This assumes that there's no variable width
//                // encoding that doesn't support ASCII.
//                $ret[self::unsafeIconv($encoding, 'UTF-8//IGNORE', $c)] = $c;
//            }
//        }
//        $encodings[$encoding] = $ret;
//        return $ret;
//    }
//}




@end
