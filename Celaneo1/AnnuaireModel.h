//
//  AnnuaireModel.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnnuaireModel : NSObject <UITableViewDataSource> {
    NSArray* data;
    NSArray* filteredData;
    NSString* filter;
    BOOL filtered;
    BOOL indexShown;
    BOOL phoneShown;
}

@property (nonatomic, assign) BOOL filtered;
@property (nonatomic, assign) BOOL indexShown;

- (void) setFilter:(NSString*)f;

@end
