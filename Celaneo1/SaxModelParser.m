//
//  SaxModelParser.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/**
 
 
 ServerRequest* t = [[ServerRequest alloc] initWithUrl:@"http://versacom.fr/t_modelparser.xml"];
 
 SaxModelParser* modelParser = [[SaxModelParser alloc] init];
 t.xmlParserDelegate = modelParser;
 modelParser.serverRequest = t;
 [t setDelegate:self];
 
 [t start];
 }
 
 - (void)serverRequest:(ServerRequest *)request didSucceedWithObject:(id)result
 {
 [result dump];
 
 Shops* ss = result;
 Shop* s = [ss.children objectAtIndex:0];  
 NSLog(@"s name %@", [s name]);
 NSLog(@"ss name %@", [ss name]);
 
 */


#import "SaxModelParser.h"

#import "BaseItem.h"

@implementation SaxModelParser
@synthesize serverRequest;
@synthesize textString;
@synthesize itemStack;
@synthesize xmlStack;

- (id) init
{
    [super init];
    self.textString = [[NSMutableString alloc] init];
    self.itemStack = [[NSMutableArray alloc] init];
    self.xmlStack = [[NSMutableArray alloc] init];
    return self;
}

- (BaseItem*) topItem
{
    return [itemStack lastObject];
}

- (void)parserDidEndDocument:(NSXMLParser *)xmlParser
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    serverRequest.erreur = parseError;
}

- (void)     parser: (NSXMLParser*) parser 
   foundCharacters: (NSString*) string 
{    
    if( string && [string length] > 0 )
    {
        [textString appendString:string];
    }
}

- (void)    parser: (NSXMLParser*) xmlParser
  didStartElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
       attributes: (NSDictionary*) attributeDict
{
    self.textString = [[NSMutableString alloc] init];
    NSString* capitalized = [elementName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[elementName substringToIndex:1] uppercaseString]];
    Class elementClass = NSClassFromString(capitalized);
    if (elementClass != nil && [elementClass instancesRespondToSelector:@selector(setModelAttribute:WithValue:)]) {
        id element = [[elementClass alloc] init];
        for (NSString* key in [attributeDict keyEnumerator]) {
            [element setModelAttribute:key WithValue:[attributeDict valueForKey:key]];
#ifdef DEBUG
            NSLog(@"%@ = %@", key, key);
#endif
        }
        if (itemStack.count == 0) {
            serverRequest.result = element;
        }
        [self.topItem addChild:element];
        [itemStack addObject:element];
        [xmlStack addObject:element];
    } else {
        [xmlStack addObject:elementName];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (![[xmlStack lastObject] isKindOfClass:[BaseItem class]]) {
#ifdef DEBUG
        NSLog(@"%@ = %@", elementName, self.textString);
#endif

        [self.topItem setModelAttribute:elementName 
                              WithValue:self.textString];
    } else {
        [self.itemStack removeLastObject];
    }
    [self.xmlStack removeLastObject];
    self.textString = nil;
}

- (void)dealloc
{
    [serverRequest release];
    [textString release];
    [itemStack release];
    [xmlStack release];
    [super dealloc];
}
@end
