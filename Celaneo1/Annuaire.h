//
//  Annuaire.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AnnuaireModel.h"
#import "BaseController.h"

@interface Annuaire : BaseController <UITableViewDelegate, UISearchBarDelegate> {
    IBOutlet UITableView* table;
    AnnuaireModel* model;
    
    UISearchBar* searchBar;
    UIView* searchOverlay;
}
@property (nonatomic, retain) AnnuaireModel* model;
@property (nonatomic, retain) IBOutlet UITableView* table;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) IBOutlet UIView* searchOverlay;
@end
