//
//  SaxMethodParser.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerRequest.h"


@protocol ApplicationParser <NSObject>

- (NSError*) endDocument;

@end

@interface SaxMethodParser : NSObject <NSXMLParserDelegate> {
    ServerRequest* serverRequest;
    
    NSMutableString* currentTextString;   
    
    id<ApplicationParser> parser; 
}
@property (nonatomic, retain) ServerRequest *serverRequest;
@property (nonatomic, retain) NSMutableString *currentTextString;
@property (nonatomic, retain) id<ApplicationParser> parser;

@end
