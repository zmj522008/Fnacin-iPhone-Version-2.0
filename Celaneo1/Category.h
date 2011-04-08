//
//  Cateogry.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"

@interface Category : NSObject <ModelObject> {
    int categoryId;
    NSString* name;
}
@property (nonatomic, assign) int categoryId;
@property (nonatomic, retain) NSString *name;

@end
