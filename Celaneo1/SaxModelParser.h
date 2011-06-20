//
//  SaxModelParser.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerRequest.h"

@interface SaxModelParser : NSObject <NSXMLParserDelegate> {
    ServerRequest* serverRequest;
    
    NSMutableString* textString;
    NSMutableArray* itemStack;
    NSMutableArray* xmlStack;
        
    BOOL inAttributeTag;
}
@property (nonatomic, retain) ServerRequest *serverRequest;
@property (nonatomic, retain) NSMutableString *textString;
@property (nonatomic, retain) NSMutableArray *itemStack;
@property (nonatomic, retain) NSMutableArray *xmlStack;

@end

