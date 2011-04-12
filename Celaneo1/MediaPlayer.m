//
//  MediaPlayer.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaPlayer.h"


@implementation MediaPlayer

@synthesize movieUrl;
@synthesize movieTitle;
@synthesize moviePlayer;

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
    [movieUrl release];
    [movieTitle release];
    [moviePlayer release];
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

}

- (void)viewWillAppear:(BOOL)animated
{
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(mediaPlayerDone:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    
    self.view = moviePlayer.view;
//    [self.view addSubview:moviePlayer.view];

    [moviePlayer play];
    
//    self.tabBarItem.title = movieTitle;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [moviePlayer stop];
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
