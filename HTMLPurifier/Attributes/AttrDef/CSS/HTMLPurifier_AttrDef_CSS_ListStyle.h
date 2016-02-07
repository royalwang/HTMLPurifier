//
//   HTMLPurifier_AttrDef_CSS_ListStyle.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef.h"

/**
 * Validates shorthand CSS property list-style.
 * @warning Does not support url tokens that have internal spaces.
 */

@interface HTMLPurifier_AttrDef_CSS_ListStyle : HTMLPurifier_AttrDef


@property NSDictionary* info;



- (id)initWithConfig:(HTMLPurifier_Config*)config;

- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;


@end
