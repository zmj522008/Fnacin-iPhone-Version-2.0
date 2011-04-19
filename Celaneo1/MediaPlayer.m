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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString* url = article.urlMedia;

    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    movieTitle.text = article.titre;
    
    if (article.type == ARTICLE_TYPE_AUDIO) {
        self.image.image = [UIImage imageNamed:@"loading_detail.jpg"];
        
        imageRequest.delegate = nil;
        [imageRequest cancel];
        self.imageRequest = [article createImageRequestForViewSize:self.image.bounds.size];
        self.imageRequest.delegate = self;
        [self.imageRequest start];
    }
    
    NSError *error;
    
    if (![[GANTracker sharedTracker] trackPageview:@"mediaPlayer"
                                         withError:&error]) {
        // Handle error here
    }
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
     name: MPMoviePlayerPlaybackStateDidChangeNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerExitFullscreen:)
     name: MPMoviePlayerWillExitFullscreenNotification
     object: moviePlayer];

    [self.playerParentView addSubview:moviePlayer.view];
    if (article.type == ARTICLE_TYPE_AUDIO) {
        CGRect bounds = self.playerParentView.bounds;
        moviePlayer.view.frame = 
            CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - AUDIO_HEIGHT,
                       bounds.size.width, AUDIO_HEIGHT);
    } else {
        moviePlayer.view.frame = self.playerParentView.bounds;
    }
    
    [moviePlayer play];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    BOOL fullScreen = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    moviePlayer.fullscreen = fullScreen;
//    [UIApplication sharedApplication].statusBarHidden = fullScreen;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    imageRequest.delegate = nil;
    [imageRequest cancel];
    self.imageRequest = nil;
    
    [moviePlayer stop];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request == imageRequest) {
        self.image.image = [UIImage imageWithData:request.responseData];
        self.imageRequest = nil;
    }
}

-(void) mediaPlayerExitFullscreen: (NSNotification*) aNotification
{
//    MPMoviePlayerController* player = [aNotification object];
}

-(void) mediaPlayerStateChange: (NSNotification*) aNotification
{
    MPMoviePlayerController* player = [aNotification object];

    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        [player stop];
    }
}

// When the movie is done, release the controller.
-(void) mediaPlayerDone: (NSNotification*) aNotification
{
    MPMoviePlayerController* player = [aNotification object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackStateDidChangeNotification
     object: player];
    
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerWillExitFullscreenNotification
     object: player];
    
    // Release the movie instance created in playMovieAtURL:
    [player release];
    
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

@end

@implementation UITabBarController (OrientatingController)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController* viewController = ((UINavigationController*)(self.selectedViewController)).topViewController;
        
        return [viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

@end
