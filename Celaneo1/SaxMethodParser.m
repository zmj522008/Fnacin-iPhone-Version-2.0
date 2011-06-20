//
//  SaxMethodParser.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SaxMethodParser.h"


@implementation SaxMethodParser
@synthesize serverRequest;
@synthesize currentTextString;
@synthesize parser;

- (void)parserDidEndDocument:(NSXMLParser *)xmlParser
{
    NSError* error = [parser endDocument];
    if (error != nil) {
        serverRequest.erreur = error;
    }
    serverRequest.result = parser;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    serverRequest.erreur = parseError;
}

-(void)     parser: (NSXMLParser*) parser 
   foundCharacters: (NSString*) string 
{    
    if( string && [string length] > 0 )
    {
        if( !currentTextString )
        {
            self.currentTextString = [[NSMutableString alloc] init];
        }
        [currentTextString appendString:string];
    }
}

-(void)    parser: (NSXMLParser*) xmlParser
  didStartElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
       attributes: (NSDictionary*) attributeDict
{
    if (self.currentTextString) 
    {
        self.currentTextString = nil;
    }
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementStart_%@:", elementName] );
    if( [parser respondsToSelector:sel] )
    {
        [parser performSelector:sel withObject: attributeDict];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"handleElementEnd_%@", elementName]);
    if ([parser respondsToSelector:sel]) {
        [parser performSelector:sel];
    } else {
        SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@:", elementName] );
        
        if( [parser respondsToSelector:sel] )
        {
            [parser performSelector:sel withObject: [currentTextString stringByTrimmingCharactersInSet:
                                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
}

- (void)dealloc
{
    [serverRequest release];
    [currentTextString release];
    [parser release];
    
    [super dealloc];
}
@end
