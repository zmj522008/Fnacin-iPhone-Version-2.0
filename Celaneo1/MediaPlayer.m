//
//  MediaPlayer.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaPlayer.h"


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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.playerParentView = nil;
    self.image = nil;
    self.movieTitle = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:article.urlMedia]];
    
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerDone:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    
    [self.playerParentView addSubview:moviePlayer.view];
    moviePlayer.view.frame = self.playerParentView.bounds;

    [moviePlayer play];
    
    movieTitle.text = article.titre;

    self.imageRequest = [article startImageRequestWithWidth:image.bounds.size.width 
                                            withHeight:image.bounds.size.height toDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
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

// When the movie is done, release the controller.
-(void) mediaPlayerDone: (NSNotification*) aNotification
{
    MPMoviePlayerController* player = [aNotification object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: player];
    
    // Release the movie instance created in playMovieAtURL:
    [player release];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
