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

- (NSString*) textDetail:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case sectionPhones: {
            PhoneValue* pv = [personne.telephones objectAtIndex:indexPath.row];
            return pv.phone;
        }
        case sectionFonction:
            return personne.fonction;
        case sectionComment:
            return personne.commentaire;
        case sectionEmail:
            return personne.email;
        case sectionAddress:
            return [NSString stringWithFormat:@"%@\n%@ %@", personne.adresse, personne.codepostal, personne.ville];
        case sectionSite:
           return personne.site;
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    switch (indexPath.section) {
        case sectionPhones: {
            PhoneValue* pv = [personne.telephones objectAtIndex:indexPath.row];
            cell.textLabel.text = pv.key;
        }
            break;
        case sectionFonction:
            cell.textLabel.text = @"fonction";
            break;
        case sectionComment:
            cell.textLabel.text = @"notes";
            break;
        case sectionEmail:
            cell.textLabel.text = @"email";
            break;
        case sectionAddress:
            cell.textLabel.text = @"adresse";
            break;
        case sectionSite:
            cell.textLabel.text = @"site";
            break;
    }
    cell.detailTextLabel.text = [self textDetail:indexPath];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* text = [self textDetail:indexPath];
    float width = tableView.bounds.size.width - 150;
    CGSize bound = CGSizeMake(width, CGFLOAT_MAX);
    float h = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:bound lineBreakMode:UILineBreakModeWordWrap].height;
    return h + 30;
}

#pragma mark contacts
- (void) saveInContacts
{
    CFErrorRef  error = NULL;
    ABAddressBookRef addressBook= ABAddressBookCreateWithOptions(NULL, &error);

    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook,^(bool granted, CFErrorRef error){
            accessGranted=granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }else{
        accessGranted=YES;

    }
    if (accessGranted) {
        
	//ABAddressBookRef addressBook = ABAddressBookCreate();
   
    ABRecordRef aRecord = ABPersonCreate(); 
    
	NSLog(@"adressBook:%@",addressBook);

	ABRecordSetValue(aRecord, kABPersonFirstNameProperty,personne.prenom, &error); 
	ABRecordSetValue(aRecord, kABPersonLastNameProperty, personne.nom, &error);

    if (personne.fonction.length > 0) {
        ABRecordSetValue(aRecord, kABPersonJobTitleProperty,personne.fonction, &error); 
    }
    ABMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (personne.telephone_fax.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_fax, kABPersonPhoneWorkFAXLabel, nil);    
    }
    if (personne.telephone_fixe.length > 0) {
       // ABMultiValueAddValueAndLabel(phones, personne.telephone_fixe, kABPersonPhoneMainLabel, nil);
        ABMultiValueAddValueAndLabel(phones, personne.telephone_fixe, kABWorkLabel, nil);

    }
    if (personne.telephone_interne.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_interne, kABPersonPhonePagerLabel, nil);    
    }
    if (personne.telephone_mobile.length > 0) {
        ABMultiValueAddValueAndLabel(phones, personne.telephone_mobile, kABPersonPhoneMobileLabel, nil);    
    }
	ABRecordSetValue(aRecord, kABPersonPhoneProperty, phones, &error);
    
   ABMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
     if (personne.email.length > 0) {
        //ABMultiValueAddValueAndLabel(emails, personne.email, kABPersonEmailProperty, nil);
       // ABRecordSetValue(aRecord, kABPersonEmailProperty, personne.email, &error);
    }
    
    if (personne.site_nom.length > 0) {
        ABRecordSetValue(aRecord, kABPersonOrganizationProperty, personne.site_nom, &error);
    }
    
	if (error != NULL) { 		
		NSLog(@"error while creating.. %@", error);
	} 
    NSLog(@"aRecord:%@",aRecord);
  
        BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&error);
        
        NSLog(@"added: %d", isAdded);
        BOOL isSaved = ABAddressBookSave (
                                          addressBook,
                                          &error
                                          );
        
        NSLog(@"saved: %d", isSaved);

	
	if (error != NULL) {
		NSLog(@"ABAddressBookAddRecord %@", error);
	} 
//	error = NULL;
	
	
	
	if (error != NULL) {
		NSLog(@"ABAddressBookSave %@", error);
	} 
	
	CFRelease(aRecord); 
	CFRelease(addressBook);
    CFRelease(phones);
    CFRelease(emails);
    }
    
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
