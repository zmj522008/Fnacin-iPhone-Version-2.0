//
//  Personne.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Personne.h"

@implementation PhoneValue
@synthesize key;
@synthesize phone;


+ (id)phoneValueWithKey:(NSString*)aKey phone:(NSString*)aPhone 
{
    PhoneValue* s = [[[PhoneValue alloc] init] autorelease];
    if (s) {
        s.key = [aKey retain];
        s.phone = [aPhone retain];
    }
    return s;
}


- (void)dealloc
{
    [key release];
    [phone release];
    [super dealloc];
}

@end

@implementation Personne
@synthesize sId;

@synthesize civilite;
@synthesize nom;
@synthesize prenom;
@synthesize telephone_fixe;
@synthesize telephone_interne;
@synthesize telephone_mobile;
@synthesize telephone_fax;
@synthesize email;
@synthesize num_bureau;
@synthesize fonction;
@synthesize site;
@synthesize adresse;
@synthesize codepostal;
@synthesize commentaire;
@synthesize site_nom;
@synthesize site_pays;
@synthesize site_region;
@synthesize phoneDigits;
@synthesize ville;

- (void) test
{
    self.civilite = @"M";
    self.nom = @"Bob";
    self.prenom = @"Dylan";
    self.telephone_fixe = @"01 02 03 04 05F";
    self.telephone_interne = @"01 02 03 04 05I";
    self.telephone_mobile = @"01 02 03 04 05M";
    self.telephone_fax = @"01 02 03 04 05F";
    self.email = @"bob.dylan@fnac.com";
    self.num_bureau = @"007";
    self.fonction = @"Singer in singing department";
    self.site = @"site";
    self.adresse = @"22, addresse de bob";
    self.codepostal = @"77777";
    self.commentaire = @"bob is a singer who was a very happy singer. He did sing songs while thinking about singing.";
    self.site_nom = @"site nom";
    self.site_pays = @"site pays";
    self.site_region = @"site region";
    self.ville = @"ville de dylan";
    [self genPhoneDigits];
}

- (int)compare:(Personne*)p
{
    int r = [nom localizedCaseInsensitiveCompare:p.nom];
    if (r == 0) {
        [prenom localizedCaseInsensitiveCompare:p.prenom];
    }
    return r;
}

- (void) doAddPhoneDigits:(NSString*) phone To:(NSMutableString*) target {
    for (int i = 0; i < phone.length; i++) {
        char c = (char) [phone characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [target appendFormat:@"%c", c];
        }
    }
    [target appendString:@" "];
}

- (void) genPhoneDigits
{
    NSMutableString* digits = [NSMutableString stringWithCapacity:10];
    for (PhoneValue* pv in [self telephones]) {
        [self doAddPhoneDigits:pv.phone To:digits];
    }
    self.phoneDigits = [NSString stringWithString:digits];
}

- (void)dump
{
    NSLog(@"P: %@ %@,T:%@,%@,%@,%@,E:%@,B:%@,F:%@,S:%@,A:%@,C:%@,C:%@,S:%@,%@,%@,Digits:%@", nom, prenom, 
          telephone_fixe, telephone_interne, telephone_mobile, telephone_fax, 
          email, num_bureau, fonction, site, adresse,
          codepostal, commentaire, site_nom, site_pays, site_region, phoneDigits);
}

- (NSArray*) telephones
{
    NSMutableArray* r = [NSMutableArray arrayWithCapacity:1];
    if (telephone_fax.length > 0) {
        [r addObject:[PhoneValue phoneValueWithKey:@"fax" phone:telephone_fax]];        
    }
    if (telephone_fixe.length > 0) {
        [r addObject:[PhoneValue phoneValueWithKey:@"fixe" phone:telephone_fixe]];        
    }
    if (telephone_interne.length > 0) {
        [r addObject:[PhoneValue phoneValueWithKey:@"interne" phone:telephone_interne]];        
    }
    if (telephone_mobile.length > 0) {
        [r addObject:[PhoneValue phoneValueWithKey:@"mobile" phone:telephone_mobile]];        
    }
    return r;
}

- (void)dealloc
{
    [civilite release];
    [nom release];
    [prenom release];
    [telephone_fixe release];
    [telephone_interne release];
    [telephone_mobile release];
    [telephone_fax release];
    [email release];
    [num_bureau release];
    [fonction release];
    [site release];
    [adresse release];
    [codepostal release];
    [commentaire release];
    [site_nom release];
    [site_pays release];
    [site_region release];
    [phoneDigits release];
    [ville release];
    
    [super dealloc];
}
@end
