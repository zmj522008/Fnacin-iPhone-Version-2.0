//
//  BaseItem.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseItem : NSObject {
    NSArray* validAttributes;
    NSMutableDictionary* attributes;
    NSMutableArray* children;
}

@property (nonatomic, retain) NSArray *validAttributes;
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, retain) NSMutableArray *children;

- (void) addChild:(BaseItem*)item;
- (void) setModelAttribute:(NSString*) attr WithValue:(NSString*)value;
- (void) dump;

@end
