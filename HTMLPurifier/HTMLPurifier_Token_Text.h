//
//  HTMLPurifier_Token_Text.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token.h"

/**
 * Concrete text token class.
 *
 * Text tokens comprise of regular parsed character data (PCDATA) and raw
 * character data (from the CDATA sections). Internally, their
 * data is parsed with all entities expanded. Surprisingly, the text token
 * does have a "tag name" called #PCDATA, which is how the DTD represents it
 * in permissible child nodes.
 */
@interface HTMLPurifier_Token_Text : HTMLPurifier_Token

    /**
     * @type string
     */
@property NSString* name = '#PCDATA';
    /**< PCDATA tag name compatible with DTD. */

    /**
     * @type string
     */
@property NSString* data;
    /**< Parsed character data of text. */

    /**
     * @type bool
     */
@property BOOL isWhitespace;

    /**< Bool indicating if node is whitespace. */

- (id)initWithData:(NSString*)d isWhitespace:(BOOL)isW line:(NSInteger)l col:(NSInteger)c;


- (NSArray*)toTokenPair;


@end
