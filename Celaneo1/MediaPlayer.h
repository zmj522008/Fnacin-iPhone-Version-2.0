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

@interface MediaPlayer : BaseController {
    NSURL* movieUrl;
    NSString* movieTitle;
    MPMoviePlayerController* moviePlayer;
}
@property (nonatomic, retain) NSURL *movieUrl;
@property (nonatomic, retain) NSString *movieTitle;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;


@end
