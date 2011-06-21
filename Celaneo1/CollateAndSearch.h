//
//  CollateAndSearch.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CollateAndSearch : NSObject {
    UILocalizedIndexedCollation *collation;
}
@property(nonatomic, readonly) NSArray *sectionTitles;
@property(nonatomic, readonly) NSArray *sectionIndexTitles;

+ (id)currentCollation;
- (id)initWithCollation:(UILocalizedIndexedCollation *)_collation;

- (NSInteger)sectionForObject:(id)object collationStringSelector:(SEL)selector;
- (NSInteger)sectionForSectionIndexTitleAtIndex:(NSInteger)indexTitleIndex;
- (NSArray *)sortedArrayFromArray:(NSArray *)array collationStringSelector:(SEL)selector;
@end
