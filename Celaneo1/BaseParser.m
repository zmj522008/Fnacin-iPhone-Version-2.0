//
//  BaseParser.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseParser.h"

#import "Celaneo1AppDelegate.h"

@implementation BaseParser
@synthesize erreurDescription;

- (void) resetParsing
{
    self.erreurDescription = nil;
}

#pragma mark Application XML Parsing - error

- (void) handleElementEnd_code:(NSString*)value
{
    erreurCode = [value intValue];
}

- (void) handleElementEnd_message:(NSString*)value
{
    erreurDescription = value;
}

- (void) handleElementEnd_reauthentification:(NSString*)value
{
    if ([value intValue] == 1) {
        [Celaneo1AppDelegate getSingleton].sessionId = nil;
    }
}

- (void) handleElementEnd_erreur
{
}


@end
