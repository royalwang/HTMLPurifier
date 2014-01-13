//
//  HTMLPurifier_Strategy.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLPurifier_Config, HTMLPurifier_Context;

@interface HTMLPurifier_Strategy : NSObject

- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
