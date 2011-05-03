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

- (IBAction)cellDeleteClick:(id)sender;

@end

@interface ArticleCell : UITableViewCell <ASIHTTPRequestDelegate, UIWebViewDelegate> {
    IBOutlet UIButton* rubrique;
    IBOutlet UIButton* thematique;
    IBOutlet UILabel* titre;
    IBOutlet UILabel* date;
    IBOutlet UITextView* accrocheText;
    IBOutlet UIWebView* accroche;
    IBOutlet UIImageView* vignette;
    IBOutlet UILabel* mediaButton;
    IBOutlet UIImageView* jaimeIcon;
    IBOutlet UILabel* jaimeText;
    IBOutlet UIImageView* reactionsIcon;
    IBOutlet UILabel* reactionsText;
    IBOutlet UIButton* favorisButton;
    IBOutlet UIImageView* detailAccessory;
    
    NSString* currentImageUrl;
    
    ASIHTTPRequest* imageRequest;
    
    BOOL deleteMode;

    id<ArticleCellDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIButton *rubrique;
@property (nonatomic, retain) IBOutlet UIButton *thematique;
@property (nonatomic, retain) IBOutlet UILabel *titre;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UIWebView *accroche;
@property (nonatomic, retain) IBOutlet UITextView *accrocheText;
@property (nonatomic, retain) IBOutlet UIImageView *vignette;
@property (nonatomic, retain) IBOutlet UILabel *mediaButton;
@property (nonatomic, retain) IBOutlet UIImageView *jaimeIcon;
@property (nonatomic, retain) IBOutlet UILabel *jaimeText;
@property (nonatomic, retain) IBOutlet UIImageView *reactionsIcon;
@property (nonatomic, retain) IBOutlet UILabel *reactionsText;
@property (nonatomic, retain) IBOutlet UIButton *favorisButton;
@property (nonatomic, retain) IBOutlet UIImageView *detailAccessory;

@property (nonatomic, retain) ASIHTTPRequest *imageRequest;
@property (nonatomic, retain) NSString *currentImageUrl;

@property (nonatomic, retain) id<ArticleCellDelegate> delegate;


- (void) updateWithArticle:(Article*) article usingImageLoadingQueue:(NSOperationQueue*)imageLoadingQueue;
@end
