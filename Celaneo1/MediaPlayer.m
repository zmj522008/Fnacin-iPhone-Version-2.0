//
//  MediaPlayer.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"

#import "MediaPlayer.h"

#define AUDIO_HEIGHT 40.0

@implementation MediaPlayer

@synthesize article;
@synthesize moviePlayer;
@synthesize playerParentView;
@synthesize image;
@synthesize movieTitle;
@synthesize imageRequest;
@synthesize activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [article release];
    [moviePlayer release];
    [playerParentView release];
    [image release];
    [movieTitle release];
    imageRequest.delegate = nil;
    [imageRequest cancel];
    [imageRequest release];
    [activity release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.playerParentView = nil;
    self.image = nil;
    self.movieTitle = nil;
    imageRequest.delegate = nil;
    [self.imageRequest cancel];
    self.imageRequest = nil;
    self.activity = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString* url = article.urlMedia;
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;

    moviePlayer.controlStyle=MPMovieControlStyleEmbedded;
    moviePlayer.repeatMode = MPMovieRepeatModeNone;

    moviePlayer.shouldAutoplay=YES;
    [self.playerParentView addSubview:self.moviePlayer.view];
    movieTitle.text = article.titre;

    if (article.type == ARTICLE_TYPE_AUDIO) {
        //self.image.image = [UIImage imageNamed:@"loading_detail.jpg"];
        imageRequest.delegate = nil;
        [imageRequest cancel];
        self.imageRequest = [article createImageRequestForViewSize:self.image.bounds.size];
        self.imageRequest.delegate = self;
       [self.imageRequest start];
    }
}
- (NSString *)pageName
{
    return @"INTRAFNAC - MEDIA";
}

- (void) viewDidAppear:(BOOL)animated
{
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerDone:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerStateChange:)
     name: MPMoviePlayerLoadStateDidChangeNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerExitFullscreen:)
     name: MPMoviePlayerDidExitFullscreenNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(mediaPlayerEnterFullscreen:)
     name:MPMoviePlayerWillEnterFullscreenNotification
     object:moviePlayer];

    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentInterfaceOrientation = self.interfaceOrientation;
    CGRect bounds = self.playerParentView.bounds;
        if (article.type == ARTICLE_TYPE_AUDIO) {
            if(UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIDeviceOrientationIsLandscape(currentInterfaceOrientation)){
                  [self mediaPlayerSonViewLandscape];

        }else{
          moviePlayer.view.frame =CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - AUDIO_HEIGHT,bounds.size.width, AUDIO_HEIGHT);
   }
      
       // [[GANTracker sharedTracker] trackEvent:@"INTRAFNAC" action:@"SON" label:article.titre value:nil withError:nil];
   } else {
        if (UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIDeviceOrientationIsLandscape(currentInterfaceOrientation)) {
          
            [self mediaPlayerMovieViewLandscape];
        }else{

            moviePlayer.view.frame = self.playerParentView.bounds;

        }
       
       // [[GANTracker sharedTracker] trackEvent:@"INTRAFNAC" action:@"VIDEO" label:article.titre value:nil withError:nil];
    }
    
    [moviePlayer play];
}
-(void) viewDidLayoutSubviews{
    
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
   
    if(UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIDeviceOrientationIsLandscape(currentInterfaceOrientation)){
        if (article.type==ARTICLE_TYPE_AUDIO) {
          
            [self mediaPlayerSonViewLandscape];
        }else{
          
            [self mediaPlayerMovieViewLandscape];
        }
        }else if (UIDeviceOrientationIsPortrait(currentDeviceOrientation)||UIDeviceOrientationIsPortrait(currentInterfaceOrientation)){
        if (article.type==ARTICLE_TYPE_AUDIO) {
                       [self mediaPlayerSonViewPortrait];
        }
        else{
          
            [self mediaPlayerMovieViewPortrait];
            
        }
    }
}

-(void) mediaPlayerSonViewLandscape
{
    CGRect bounds = self.playerParentView.bounds;
    CGRect frame = self.playerParentView.frame;
    CGRect title = self.movieTitle.frame;
    CGRect imageView = self.image.frame;
    CGRect imageBounds =self.image.bounds;
    bounds.size.height = 300;
    bounds.size.width=480;
    bounds.origin.x=20;
    bounds.origin.y=0;
    frame.origin.x=0;
    frame.origin.y=20,
    frame.size.width=480;
    frame.size.height=300;
    self.playerParentView.frame=frame;
    self.playerParentView.bounds=bounds;
    title.origin.x=0;
    title.origin.y=0;
    title.size.width=480;
    title.size.height=20;
    self.movieTitle.frame = title;
    imageView.origin.x=0;
    imageView.origin.y=40;
    imageView.size.height=140;
    imageView.size.width=480;
    imageBounds.origin.x=0;
    imageBounds.origin.y=0;
    imageBounds.size.height=140;
    imageBounds.size.width=480;
    self.image.bounds=imageBounds;
    self.image.frame=imageView;
    moviePlayer.view.bounds=CGRectMake(0, 0, 480, 20);
    moviePlayer.view.frame= CGRectMake(20,170,480, 20);
}
-(void) mediaPlayerSonViewPortrait{
    CGRect bounds = self.playerParentView.bounds;
    CGRect frame = self.playerParentView.frame;
    CGRect title = self.movieTitle.frame;
    CGRect imageView = self.image.frame;
    CGRect imageBounds =self.image.bounds;
    bounds.size.height = 338;
    bounds.size.width=320;
    bounds.origin.x=0;
    bounds.origin.y=0;
    frame.origin.x=0;
    frame.origin.y=40,
    frame.size.width=320;
    frame.size.height=338;
    self.playerParentView.frame=frame;
    self.playerParentView.bounds=bounds;
    title.origin.x=0;
    title.origin.y=0;
    title.size.width=320;
    title.size.height=40;
    self.movieTitle.frame = title;
    imageView.origin.x=0;
    imageView.origin.y=90;
    imageView.size.height=192;
    imageView.size.width=320;
    imageBounds.origin.x=0;
    imageBounds.origin.y=0;
    imageBounds.size.height=192;
    imageBounds.size.width=320;
    self.image.bounds=imageBounds;
    self.image.frame=imageView;
    moviePlayer.view.frame =CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - AUDIO_HEIGHT,bounds.size.width, AUDIO_HEIGHT);
    if (moviePlayer.loadState == MPMovieLoadStatePlayable || moviePlayer.loadState == MPMovieLoadStatePlaythroughOK) {
        [activity stopAnimating];
    }
}
-(void) mediaPlayerMovieViewLandscape{
    CGRect bounds = self.playerParentView.bounds;
    CGRect frame = self.playerParentView.frame;
    CGRect title = self.movieTitle.frame;
    NSLog(@"LandscapeView-------videoPlayer");
    title.origin.x=0;
    title.origin.y=0;
    title.size.width=480;
    title.size.height=15;
    self.movieTitle.frame = title;
    bounds.origin.x=0;
    bounds.origin.y=0;
    bounds.size.width=480;
    bounds.size.height=190;
    frame.origin.x=0;
    frame.origin.y=15;
    frame.size.height=190;
    frame.size.width=480;
    self.playerParentView.bounds=bounds;
    self.playerParentView.frame=frame;
    moviePlayer.view.frame=self.playerParentView.frame;
    moviePlayer.view.bounds=self.playerParentView.bounds;
    NSLog(@"moviePlayer------width:%f",moviePlayer.view.frame.size.width);
    NSLog(@"moviePlayer------height:%f",moviePlayer.view.frame.size.height);


}
-(void) mediaPlayerMovieViewPortrait{
    CGRect bounds = self.playerParentView.bounds;
    CGRect frame = self.playerParentView.frame;
    CGRect title = self.movieTitle.frame;
    title.origin.x=0;
    title.origin.y=0;
    title.size.width=320;
    title.size.height=40;
    self.movieTitle.frame = title;
    bounds.origin.x=0;
    bounds.origin.y=0;
    bounds.size.width=320;
    bounds.size.height=338;
    frame.origin.x=0;
    frame.origin.y=40;
    frame.size.height=338;
    frame.size.width=320;
    self.playerParentView.bounds=bounds;
    self.playerParentView.frame=frame;
    moviePlayer.view.frame=self.playerParentView.bounds;
}
/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    BOOL fullScreen = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
 
    moviePlayer.fullscreen = fullScreen;
 [UIApplication sharedApplication].statusBarHidden = fullScreen;
    
}
*/
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    imageRequest.delegate = nil;
    [imageRequest cancel];
    self.imageRequest = nil;
    
    //[moviePlayer stop];

}
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    imageRequest.delegate = nil;
    [imageRequest cancel];
    self.imageRequest = nil;
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerExitedFullscreen:)
     name: MPMoviePlayerDidExitFullscreenNotification
     object: moviePlayer];
    if (self.moviePlayer.isFullscreen==0) {
        [moviePlayer stop];
        [moviePlayer.view removeFromSuperview];
        [moviePlayer autorelease];

    }
        

    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (article.type == ARTICLE_TYPE_AUDIO) {
        self.image.image = [UIImage imageWithData:request.responseData];
    }
    if (request == imageRequest) {
        self.image.image = [UIImage imageWithData:request.responseData];
        self.imageRequest = nil;
    }
}
-(void) requestFailed:(ASIHTTPRequest *)request{
    if (article.type == ARTICLE_TYPE_AUDIO) {
        self.image.image = [UIImage imageNamed:@"loading_detail.jpg"];
    }
    
}
-(void) mediaPlayerExitFullscreen: (NSNotification*) aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
        [moviePlayer stop];
        [moviePlayer.view removeFromSuperview];
        [moviePlayer autorelease];
}

-(void) mediaPlayerEnterFullscreen: (NSNotification*) aNotification{

    moviePlayer.fullscreen=YES;
}

-(void) mediaPlayerExitedFullscreen:(NSNotification*) aNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [moviePlayer stop];
    [moviePlayer.view removeFromSuperview];
    [moviePlayer autorelease];
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"view did disappear exit fullscreen");

    
}
-(void) mediaPlayerStateChange: (NSNotification*) aNotification
{
    NSLog(@"State changed");
    if (moviePlayer.loadState == MPMovieLoadStatePlayable || moviePlayer.loadState == MPMovieLoadStatePlaythroughOK) {
        NSLog(@"playableOK");
        [activity stopAnimating];
    }else if(moviePlayer.loadState==MPMovieLoadStateStalled){
        NSLog(@"Stalled");
    }else if(moviePlayer.loadState == MPMovieLoadStateUnknown){
       
        NSLog(@"UnknownState");
        [moviePlayer stop];
        [moviePlayer.view removeFromSuperview];
        [moviePlayer autorelease];
    }
}

// When the movie is done, release the controller.
-(void) mediaPlayerDone: (NSNotification*) aNotification
{    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerLoadStateDidChangeNotification
     object: moviePlayer];
    
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerWillExitFullscreenNotification
     object: moviePlayer];
    
    self.moviePlayer = nil;
    
    if (self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            return article.type == ARTICLE_TYPE_VIDEO;
        } else {
            return NO;
        }
    }
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

@implementation UITabBarController (OrientatingController)

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController* viewController = ((UINavigationController*)(self.selectedViewController)).topViewController;
        
        return [viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }
}*/

@end
