//
//  SiteGroupController.m
//  Celaneo1
//
//  Created by Mingjun Zheng on 04/06/13.
//
//

#import "SiteGroupController.h"

@interface SiteGroupController ()

@end

@implementation SiteGroupController

@synthesize siteurl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage* buttonBack = [[UIImage imageNamed:@"btn_left.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.siteurl.text = @"http://www.groupe-fnac.com/";
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnLink:)];
    [siteurl setUserInteractionEnabled:YES];
    [siteurl addGestureRecognizer:gesture];

}
- (void)userTappedOnLink:(UIGestureRecognizer*)gestureRecognizer{
    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://www.groupe-fnac.com/" ];
    [[UIApplication sharedApplication] openURL:url];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
