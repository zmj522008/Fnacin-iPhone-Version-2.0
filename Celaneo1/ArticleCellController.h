//
//  ArticleCell.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Article.h"
#import "ASIHTTPRequest.h"

@protocol ArticleCellDelegate <NSObject>

- (void) articleShowContent:(Article*) article;
- (void) article:(Article*) article playMediaUrl:(NSString*) url withType:(int)type;
- (void) articleShowRubrique:(int) rubriqueId;
- (void) articleShowThematique:(int) thematiqueId;
- (void) article:(Article*) article makeFavoris:(BOOL) favoris;

@end

@interface ArticleCellController : UIViewController <ASIHTTPRequestDelegate> {
    Article* article;
    
    IBOutlet UIButton* rubrique;
    IBOutlet UIButton* thematique;
    IBOutlet UILabel* titre;
    IBOutlet UILabel* date;
    IBOutlet UIWebView* accroche;
    IBOutlet UIImageView* vignette;
    IBOutlet UIImageView* mediaButton;
    IBOutlet UIImageView* jaimeIcon;
    IBOutlet UILabel* jaimeText;
    IBOutlet UIImageView* reactionsIcon;
    IBOutlet UILabel* reactionsText;
    IBOutlet UIButton* favorisButton;
    IBOutlet UIImageView* detailAccessory;
    
    id<ArticleCellDelegate> delegate;
    
    NSOperationQueue* imageLoadingQueue;
    ASIHTTPRequest* imageRequest;
}
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) IBOutlet UIButton *rubrique;
@property (nonatomic, retain) IBOutlet UIButton *thematique;
@property (nonatomic, retain) IBOutlet UILabel *titre;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UIWebView *accroche;
@property (nonatomic, retain) IBOutlet UIImageView *vignette;
@property (nonatomic, retain) IBOutlet UIImageView *mediaButton;
@property (nonatomic, retain) IBOutlet UIImageView *jaimeIcon;
@property (nonatomic, retain) IBOutlet UILabel *jaimeText;
@property (nonatomic, retain) IBOutlet UIImageView *reactionsIcon;
@property (nonatomic, retain) IBOutlet UILabel *reactionsText;
@property (nonatomic, retain) IBOutlet UIButton *favorisButton;
@property (nonatomic, retain) IBOutlet UIImageView *detailAccessory;

@property (nonatomic, assign) id<ArticleCellDelegate> delegate;
@property (nonatomic, retain) NSOperationQueue *imageLoadingQueue;
@property (nonatomic, retain) ASIHTTPRequest *imageRequest;

- (void) update;
- (IBAction) mediaClick;
- (IBAction) contentClick;
- (IBAction) rubriqueClick;
- (IBAction) thematiqueClick;
- (IBAction) favorisClick;

@end
