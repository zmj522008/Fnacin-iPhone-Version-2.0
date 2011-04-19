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
#import "ArticleCell.h"

@interface ArticleList : BaseController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray* articles;
    
    BOOL favoris;
    BOOL prefere;
    BOOL podcast;
    int rubriqueId;
    int thematiqueId;
    int magasinId;
    
    BOOL hasMore;
    
    IBOutlet UITableView* table;
}
@property (nonatomic, retain) NSMutableArray *articles;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, assign, getter=isFavoris) BOOL favoris;
@property (nonatomic, assign, getter=isPrefere) BOOL prefere;
@property (nonatomic, assign, getter=isPodcast) BOOL podcast;
@property (nonatomic, assign) int rubriqueId;
@property (nonatomic, assign) int thematiqueId;
@property (nonatomic, assign) int magasinId;

- (IBAction) cellMediaClick:(id)sender;
- (IBAction) cellContentClick:(id)sender;
- (IBAction) cellRubriqueClick:(id)sender;
- (IBAction) cellThematiqueClick:(id)sender;
- (IBAction) cellFavorisClick:(id)sender;

@end
