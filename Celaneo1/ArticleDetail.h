//
//  ArticleDetail.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

#import "Article.h"

enum ArticleDetailSections {
    ArticleDetailSection_Details,
    ArticleDetailSection_Content,
    ArticleDetailSection_FnacCom,
    ArticleDetailSection_PostComment,
    ArticleDetailSection_Comments,
    ArticleDetailSection_count
};

@interface ArticleDetail : BaseController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UITextViewDelegate> {
    Article* article;
    
    ServerRequest* commentaireRequest;
    ServerRequest* favorisRequest;
    ServerRequest* jaimeRequest;

    IBOutlet UITableView* table;
    IBOutlet UIBarButtonItem* jaime;
    IBOutlet UIBarButtonItem* commentaire;
    IBOutlet UIBarButtonItem* favoris;
    
    IBOutlet UITableViewCell* detailCell;
    IBOutlet UITableViewCell* contentCell;
    IBOutlet UITableViewCell* postCommentCell;
    IBOutlet UITableViewCell* fnaccomCell;
    
    IBOutlet UIActivityIndicatorView* activityIndicator;
    IBOutlet UIToolbar* toolbar;
    
#pragma mark detail cell attributes
    IBOutlet UIButton* rubrique;
    IBOutlet UIButton* thematique;
    IBOutlet UILabel* titre;
    IBOutlet UIImageView* vignette;
    IBOutlet UILabel* mediaButton;

    ASIHTTPRequest* imageRequest;

#pragma mark content cell
    IBOutlet UIWebView* content;

#pragma mark post comment cell
    IBOutlet UIButton* commentToggle;
    IBOutlet UITextView* commentText;
    IBOutlet UIButton* commentSend;
    IBOutlet UIButton* commentCancel;
    IBOutlet UILabel* commentCount;
    
    float detailCellHeight;
    float contentCellHeight;
    float postCommentaireCellHeight;
    
    Boolean keyboardIsShowing;
    CGRect keyboardBounds;
}

- (IBAction) jaimeClick;
- (IBAction) commentaireClick;
- (IBAction) favorisClick;

- (IBAction) mediaClick;

- (IBAction) toggleCommentaireView;

- (IBAction) submitCommentaire;
- (IBAction) fnaccomClick;

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) ServerRequest *commentaireRequest;
@property (nonatomic, retain) ServerRequest *favorisRequest;
@property (nonatomic, retain) ServerRequest *jaimeRequest;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *jaime;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *commentaire;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *favoris;
@property (nonatomic, retain) IBOutlet UITableViewCell *detailCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *contentCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *postCommentCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *fnaccomCell;
@property (nonatomic, retain) IBOutlet UIButton *rubrique;
@property (nonatomic, retain) IBOutlet UIButton *thematique;
@property (nonatomic, retain) IBOutlet UILabel *titre;
@property (nonatomic, retain) IBOutlet UIImageView *vignette;
@property (nonatomic, retain) IBOutlet UILabel *mediaButton;
@property (nonatomic, retain) ASIHTTPRequest *imageRequest;
@property (nonatomic, retain) IBOutlet UIWebView *content;
@property (nonatomic, retain) IBOutlet UIButton *commentToggle;
@property (nonatomic, retain) IBOutlet UILabel *commentCount;
@property (nonatomic, retain) IBOutlet UITextView *commentText;
@property (nonatomic, retain) IBOutlet UIButton *commentSend;
@property (nonatomic, retain) IBOutlet UIButton *commentCancel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (void) update;
- (void) resizeViewControllerToFitScreen;
@end
