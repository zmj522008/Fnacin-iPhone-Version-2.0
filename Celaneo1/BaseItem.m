//
//  BaseItem.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseItem.h"

#include <objc/runtime.h>

id attributeGetter(id self, SEL _cmd) {
    NSString* attr = [NSString stringWithCString:sel_getName(_cmd) encoding:NSASCIIStringEncoding];
    if ([[self validAttributes] containsObject:attr]) {
        return [[self attributes] objectForKey:attr];
    } else {
        return nil;
    }
}

@implementation BaseItem
@synthesize validAttributes;
@synthesize attributes;
@synthesize children;

- (id) init
{
    self.children = [NSMutableArray arrayWithCapacity:1];
    self.attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

- (void) setModelAttribute:(NSString*) attr WithValue:(NSString*)value
{
    [attributes setObject:value forKey:attr];
}

- (void)addChild:(BaseItem *)item
{
    [children addObject:item];
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    // We do not provide any checking here. We will check everything in attribute getter
    
    class_addMethod([self class], aSEL, (IMP) attributeGetter, "@@:");
    return YES;

    return [super resolveInstanceMethod:aSEL];
}

- (void) dump:(int)level
{
    NSMutableString* str = [NSMutableString stringWithCapacity:1];
    [str appendString:[@"" stringByPaddingToLength:level withString:@" " startingAtIndex:0]];
    [str appendFormat:@"%s ", class_getName([self class])];
    BOOL first = YES;
    for (NSString* attrName in self.validAttributes) {
        if (!first) {
            [str appendString:@","];
        } 
        first = NO;
        [str appendFormat:@"%@ = '%@'", attrName, [[self attributes] objectForKey:attrName]];
    }
    NSLog(@"%@", str);
    for (BaseItem* item in self.children) {
        [item dump:level + 1];
    }
}

- (void) dump
{
    [self dump:0];
}
- (void) dealloc
{
    [validAttributes release];
    [attributes release];
    [children release];
    [super dealloc];
}
@end
