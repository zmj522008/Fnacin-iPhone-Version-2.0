//
//  MediaPlayer.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "BaseController.h"
#import "ASIHTTPRequest.h"
#import "Article.h"

@interface MediaPlayer : BaseController <ASIHTTPRequestDelegate> {
    Article* article;
    
    MPMoviePlayerController* moviePlayer;
    
    IBOutlet UILabel* movieTitle;
    IBOutlet UIView* playerParentView;
    IBOutlet UIImageView* image;
    IBOutlet UIActivityIndicatorView* activity;
    
    ASIHTTPRequest* imageRequest;
}
@property (nonatomic, retain) Article* article;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

@property (nonatomic, retain) IBOutlet UILabel* movieTitle;
@property (nonatomic, retain) IBOutlet UIView *playerParentView;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) ASIHTTPRequest* imageRequest;

@end
