//
//  BaseParser.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseParser : NSObject {
    NSString* erreurDescription;
    int erreurCode;
}

@property (nonatomic, retain) NSString *erreurDescription;

- (void) resetParsing;

@end
