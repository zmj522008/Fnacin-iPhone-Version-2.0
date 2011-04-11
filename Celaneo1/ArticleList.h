//
//  FirstViewController.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "ServerRequest.h"
#import "ArticleCellController.h"

@interface ArticleList : BaseController <UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate> {
    NSArray* articles;
    
    BOOL favoris;
    BOOL prefere;
    BOOL podcast;
    int rubriqueId;
    int thematiqueId;
    int magasinId;
    
    BOOL resetCache;
    
    IBOutlet UITableView* table;
}
@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, retain) IBOutlet UITableView *table;

@end
