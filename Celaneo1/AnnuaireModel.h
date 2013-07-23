//
//  AnnuaireModel.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AnnuaireDB.h"

extern NSString *const AnnuaireModelDataStatusChange;

@interface AnnuaireModel : NSObject <UITableViewDataSource> {
    NSArray* data;
    NSArray* filteredData;
    NSString* currentFilter;
    
    NSArray *listItems;
    
    int dataCount;
    
    BOOL filtered;
    BOOL indexShown;
    BOOL phoneShown;
    
    BOOL fetching;
    BOOL syncing;
}

@property (nonatomic, assign) BOOL filtered;
@property (nonatomic, assign) BOOL indexShown;
@property (nonatomic, assign, readonly) BOOL fetching;
@property (nonatomic, assign) BOOL syncing;

- (Personne*) detailPersonneAtIndexPath:(NSIndexPath*)indexPath;

- (void) setFilter:(NSString*)f;
- (void) fetchData;
@end
