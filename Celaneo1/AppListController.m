//
//  AppListController.m
//  Celaneo1
//
//  Created by Camille Benhamou on 03/10/12.
//
//

#import "AppListController.h"

@interface AppListController ()
    
@end

@implementation AppListController

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
    UIImage* buttonBack = [[UIImage imageNamed:@"btn_left.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    self.navigationItem.title = @" ";

    _dataToShow = [[NSArray alloc] initWithObjects:@" Appli mobile Fnac.com", @"Adhérent Club Fnac", @"Tick&Live", @"MarketPlace", @"LaboFnac", @"Kobo by FNAC", nil];
    
    _iconArray = [[NSArray alloc] initWithObjects:  @"120x120 MobileFnac.png", @"120x120 iconeAdherentClubFnac_iOS.png",@"icone_Tick_Live.png", @"120x120 FnacCom.png", @"120x120 logo_app_labo_fnac.png", @"icone_Kobo_by_Fnac.png", nil];
    
    _linkArray = [[NSArray alloc] initWithObjects:@"http://itunes.apple.com/fr/app/fnac/id377379474?mt=8&uo=4", @"https://itunes.apple.com/fr/app/adherent-club-fnac/id550143546?mt=8&uo=4",@"http://itunes.apple.com/fr/app/tick-live/id337877075?mt=8&uo=4",@"http://itunes.apple.com/fr/app/fnac-marketplace/id372315991?mt=8&uo=4",  @"https://itunes.apple.com/fr/app/labofnac/id546283144?mt=8&uo=4", @"https://itunes.apple.com/fr/app/kobo-by-fnac/id480683940?mt=8&uo=4",nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataToShow count];
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_linkArray objectAtIndex:[indexPath row]]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_dataToShow objectAtIndex:[indexPath row]];
    
    cell.imageView.image = [UIImage imageNamed:[_iconArray objectAtIndex:[indexPath row]]];


    return cell;
    
}
@end
