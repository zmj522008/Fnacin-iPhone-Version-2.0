//
//  LoginPageController.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"

@interface LoginController : UIViewController <ServerRequestDelegate> {
    IBOutlet UITextField* email;
    IBOutlet UITextField* password;
    IBOutlet UIButton* submitButton;
    
    ServerRequest* request;
}

@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *submitButton;
@property (nonatomic, retain) ServerRequest* request;

- (IBAction) submit;
- (IBAction) recoverPassword;
- (IBAction) selectPassword;
- (IBAction) onChange;

@end
