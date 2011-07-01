//
//  annuaireDetail.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "annuaireDetail.h"
#import "AddressBook/AddressBook.h"

enum {
    sectionFonction,
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"➜ Contacts" action:@selector(saveInContacts)]];
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

- (NSString *)pageName
{
    return @"INTRAFNAC - ANNUAIRE - DETAIL";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case sectionFonction:
            return personne.fonction.length > 0 ? 1 : 0;
            
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
        case sectionFonction:
            cell.detailTextLabel.text = @"fonction";
            cell.textLabel.text = personne.fonction;
            break;
        case sectionComment:
            cell.detailTextLabel.text = @"commentaires";
            cell.textLabel.text = personne.commentaire;
            break;
        case sectionEmail:
            cell.detailTextLabel.text = @"email";
            cell.textLabel.text = personne.email;
            break;
        case sectionAddress:
            cell.detailTextLabel.text = @"adresse";
            cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@ %@", personne.adresse, personne.codepostal, personne.ville];
            break;
        case sectionSite:
            cell.detailTextLabel.text = @"site";
            cell.textLabel.text = personne.site;
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

#pragma mark contacts
- (void) saveInContacts
{
    ABRecordRef aRecord = ABPersonCreate(); 
	CFErrorRef  error = NULL; 
	ABRecordSetValue(aRecord, kABPersonFirstNameProperty, 
					 personne.prenom, &error); 
	ABRecordSetValue(aRecord, kABPersonLastNameProperty, 
					 personne.nom, &error); 
    if (personne.fonction.length > 0) {
        ABRecordSetValue(aRecord, kABPersonJobTitleProperty,
                         personne.fonction, &error); 
    }
    ABMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (personne.telephone_fax.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_fax, kABPersonPhoneWorkFAXLabel, nil);    
    }
    if (personne.telephone_fixe.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_fixe, kABPersonPhoneMainLabel, nil);    
    }
    if (personne.telephone_interne.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_interne, kABPersonPhonePagerLabel, nil);    
    }
    if (personne.telephone_mobile.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_mobile, kABPersonPhoneMobileLabel, nil);    
    }
	ABRecordSetValue(aRecord, kABPersonPhoneProperty, phones, &error);
    if (personne.email.length > 0) {
        ABRecordSetValue(aRecord, kABPersonEmailProperty, personne.email, &error);
    }
    if (personne.site_nom.length > 0) {
        ABRecordSetValue(aRecord, kABPersonOrganizationProperty, personne.site_nom, &error);
    }
    CFRelease(phones);
    
	if (error != NULL) { 		
		NSLog(@"error while creating.. %@", error);
	} 
	ABAddressBookRef addressBook; 
	addressBook = ABAddressBookCreate(); 
	
	BOOL isAdded = ABAddressBookAddRecord (
                                           addressBook,
                                           aRecord,
                                           &error
                                           );	
	if(isAdded){
		NSLog(@"added..");
	}
	if (error != NULL) {
		NSLog(@"ABAddressBookAddRecord %@", error);
	} 
//	error = NULL;
	
	BOOL isSaved = ABAddressBookSave (
                                      addressBook,
                                      &error
                                      );
	
	if(isSaved){
		
		NSLog(@"saved..");
	}
	
	if (error != NULL) {
		NSLog(@"ABAddressBookSave %@", error);
	} 
	
	CFRelease(aRecord); 
	CFRelease(addressBook);
    
    if (error) {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ajout"
                                                            message:@"Cette personne ne peut pas etre ajoute a vos contacts" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [errorView show];
        [errorView release];
    } else {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ajout"
                                                            message:[NSString stringWithFormat:@"%@ %@ a été ajouté à vos contacts", personne.prenom, personne.nom]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [errorView show];
        [errorView release];
        self.navigationItem.rightBarButtonItem = nil;
    }
}
@end
