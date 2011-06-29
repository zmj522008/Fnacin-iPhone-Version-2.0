//
//  annuaireDetail.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "annuaireDetail.h"


enum {
    sectionPhones,
    sectionEmail,
    sectionAddress,
    sectionSite,
    sectionComment,
    sectionCount
} Sections;

@implementation annuaireDetail
@synthesize personne;

- (void)dealloc
{
    [personne release];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case sectionPhones:
            return [personne.telephones count];

        case sectionAddress:
            return personne.adresse.length + personne.codepostal.length > 0 ? 1 : 0;
            
        case sectionComment:
            return personne.commentaire.length > 0 ? 1 : 0;
            
        case sectionEmail:
            return personne.email.length > 0 ? 1 : 0;
            
        case sectionSite:
            return personne.site.length > 0;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    switch (indexPath.section) {
        case sectionPhones: {
            PhoneValue* pv = [personne.telephones objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = pv.phone;
            cell.textLabel.text = pv.key;
        }
            break;
        case sectionAddress:
            cell.detailTextLabel.text = @"adresse";
            cell.textLabel.text = personne.adresse;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (personne.civilite.length > 0) {
            return [NSString stringWithFormat:@"%@ %@ %@", personne.civilite, personne.prenom, personne.nom];
        } else {
            return [NSString stringWithFormat:@"%@ %@", personne.prenom, personne.nom];
        }
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* url = nil;
    switch (indexPath.section) {
        case sectionPhones:
            url = [@"tel://" stringByAppendingString:[self tableView:tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text];
            break;
        case sectionEmail:
            url = [@"mailto://" stringByAppendingString:[self tableView:tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text];
            break;
    }
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
@end
