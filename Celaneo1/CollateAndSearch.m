//
//  CollateAndSearch.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CollateAndSearch.h"


@implementation CollateAndSearch

@dynamic sectionTitles;
@dynamic sectionIndexTitles;

+ (id)currentCollation;
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    return [[[self alloc] initWithCollation:collation] autorelease];
}

- (id)initWithCollation:(UILocalizedIndexedCollation *)_collation;
{
    if ((self = [super init])) {
        collation = [_collation retain];
    }
    return self;
}

- (void)dealloc;
{
    [collation release];
    [super dealloc];
}

#pragma mark -

- (NSInteger)sectionForObject:(id)object collationStringSelector:(SEL)selector
{
    return [collation sectionForObject:object collationStringSelector:selector];
}

- (NSInteger)sectionForSectionIndexTitleAtIndex:(NSInteger)indexTitleIndex
{
    if(indexTitleIndex == 0) { 
        return NSNotFound;
    }
    return [collation sectionForSectionIndexTitleAtIndex:indexTitleIndex-1];
}

- (NSArray *)sortedArrayFromArray:(NSArray *)array collationStringSelector:(SEL)selector
{
    return [collation sortedArrayFromArray:array collationStringSelector:selector];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)sectionTitles;
{
    return [collation sectionTitles];
}

- (NSArray *)sectionIndexTitles;
{
    return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[collation sectionIndexTitles]];
}

@end
