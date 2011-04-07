//
//  ArticleCell.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Article.h"

@protocol ArticleCellDelegate <NSObject>

- (void) articleShowContent:(Article*) article;
- (void) articlePlayMediaUrl:(NSString*) url withType:(int)type;
- (void) articleShowRubrique:(int) rubriqueId;
- (void) articleShowThematique:(int) url;
- (void) article:(Article*) article makeFavoris:(BOOL) favoris;

@end

@interface ArticleCellController : UIViewController {
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
    IBOutlet UIButton* favorisButton;
    
    id<ArticleCellDelegate> delegate;
}

- (IBAction) mediaClick;
- (IBAction) contentClick;
- (IBAction) rubriqueClick;
- (IBAction) thematiqueClick;
- (IBAction) favorisClick;

@end
