//
//  LoginPageController.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"

#import "BaseController.h"

@interface LoginController : BaseController <UIAlertViewDelegate> {
    IBOutlet UITextField* email;
    IBOutlet UITextField* password;
    IBOutlet UIButton* submitButton;
    IBOutlet UIButton* debugButton;
    IBOutlet UIView* emailLabel;
    IBOutlet UIView* passwordLabel;
    IBOutlet UIView* passwordRecoveryLabel;

    IBOutlet UIButton* forgottenPasswordMode;
    IBOutlet UIButton* connectMode;

    ServerRequest* request;
}

@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *submitButton;
@property (nonatomic, retain) IBOutlet UIButton *debugButton;
@property (nonatomic, retain) ServerRequest* request;

@property (nonatomic, retain) IBOutlet UIView *emailLabel;
@property (nonatomic, retain) IBOutlet UIView *passwordLabel;
@property (nonatomic, retain) IBOutlet UIView *passwordRecoveryLabel;
@property (nonatomic, retain) IBOutlet UIButton *forgottenPasswordMode;
@property (nonatomic, retain) IBOutlet UIButton *connectMode;

- (IBAction) submit;
- (IBAction) switchToRecoverPasswordMode;
- (IBAction) emailReturn;
- (IBAction) onChange;
- (IBAction) switchToConnectMode;

- (IBAction) debugBypassLog;

@end
