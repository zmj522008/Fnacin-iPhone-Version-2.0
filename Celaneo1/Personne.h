//
//  Personne.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 <civilite><![CDATA[monsieur]]></civilite>
 <nom><![CDATA[durand]]></nom>
 <prenom><![CDATA[thierry]]></prenom>
 <tel_fixe><![CDATA[01402030405]]></tel_fixe>
 <tel_interne><![CDATA[01402030405]]></tel_interne>
 <tel_mobile><![CDATA[01402030405]]></tel_mobile>
 <fax><![CDATA[01402030405]]></fax>
 <email><![CDATA[dt@ggg.fr]]></email>
 <num_bureau><![CDATA[lhlh]]></num_bureau>
 <fonction><![CDATA[llkhklh]]></fonction>
 <site><![CDATA[lhh]]></site>
 <adresse><![CDATA[lhkl]]></adresse>
 <cp><![CDATA[lkhklh]]></cp>
 <commentaire><![CDATA[klhklkh]]></commentaire>
 <site_nom><![CDATA[lhklh]]></site_nom>
 <site_pays><![CDATA[lhkklh]]></site_pays>
 <site_region><![CDATA[lhlkh]]></site_region>
*/


@interface PhoneValue : NSObject {
    NSString* key;
    NSString* phone;
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *phone;
@end;

@interface Personne : NSObject {
    int sId;
    NSString* civilite;
    NSString* nom;
    NSString* prenom;
    NSString* telephone_fixe;
    NSString* telephone_interne;
    NSString* telephone_mobile;
    NSString* telephone_fax;
    NSString* email;
    NSString* num_bureau;
    NSString* fonction;
    NSString* site;
    NSString* adresse;
    NSString* codepostal;
    NSString* commentaire;
    NSString* site_nom;
    NSString* site_pays;
    NSString* site_region;

    NSString* phoneDigits;
}
@property (assign) int sId;
@property (nonatomic, retain) NSString *civilite;
@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *prenom;
@property (nonatomic, retain) NSString *telephone_fixe;
@property (nonatomic, retain) NSString *telephone_interne;
@property (nonatomic, retain) NSString *telephone_mobile;
@property (nonatomic, retain) NSString *telephone_fax;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *num_bureau;
@property (nonatomic, retain) NSString *fonction;
@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *adresse;
@property (nonatomic, retain) NSString *codepostal;
@property (nonatomic, retain) NSString *commentaire;
@property (nonatomic, retain) NSString *site_nom;
@property (nonatomic, retain) NSString *site_pays;
@property (nonatomic, retain) NSString *site_region;
@property (nonatomic, retain) NSString *phoneDigits;

- (void) dump;
- (void) genPhoneDigits;

- (NSArray*) telephones;
@end
