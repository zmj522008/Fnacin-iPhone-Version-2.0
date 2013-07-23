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
#import "PullToRefreshView.h"

@interface ArticleList : BaseController <UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate, PullToRefreshViewDelegate> {
    
    NSMutableArray* articles;
    
    BOOL favoris;
    BOOL prefere;
    BOOL podcast;
    int rubriqueId;
    int thematiqueId;
    int magasinId;
    int newArticles;
    BOOL test;
    int tag;
    int notif;
    BOOL hasMore;
    IBOutlet UITableView* table;
    IBOutlet UITextField* fldBadgeNumber;

}
@property (nonatomic, retain) NSMutableArray *articles;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, assign, getter=isFavoris) BOOL favoris;
@property (nonatomic, assign, getter=isPrefere) BOOL prefere;
@property (nonatomic, assign, getter=isPodcast) BOOL podcast;
@property (nonatomic, assign) int rubriqueId;
@property (nonatomic, assign) int thematiqueId;
@property (nonatomic, assign) int magasinId;
@property (nonatomic,assign) UIAlertView *loadAlert;
@property (nonatomic,assign) UIActivityIndicatorView *loadIndocator;

@property (nonatomic, strong) NSMutableDictionary *prefDictionary;
- (IBAction) cellMediaClick:(id)sender;
- (IBAction) cellContentClick:(id)sender;
- (IBAction) cellRubriqueClick:(id)sender;
- (IBAction) cellThematiqueClick:(id)sender;
- (IBAction) cellFavorisClick:(id)sender;
- (IBAction) cellDeleteClick:(id)sender;
@end
