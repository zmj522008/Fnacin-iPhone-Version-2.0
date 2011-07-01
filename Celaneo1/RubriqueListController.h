//
//  SecondViewController.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface RubriqueListController : BaseController <UITableViewDataSource, UITableViewDelegate> {
    NSArray* rubriques;
    
    IBOutlet UITableView* table;
}
@property (nonatomic, retain) NSArray* rubriques;

@end
