//
//  FirstViewController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "ProfileViewController.h"

//Categories
#import "UIImageView+AFNetworking.h"

//Others
#import "MyService.h"

@interface ProfileViewController () <UITextFieldDelegate>
//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
//Discovery
@property (strong, nonatomic) DCBluetoothEmitter *bluetoothEmitter;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // create UUID's
    CBUUID *serviceUUID = [CBUUID UUIDWithString:MyServiceExampleServiceUUIDKey];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:MyServiceExampleCharacteristicUUIDKey];
    NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:MyServiceExampleUserUUIDKey];
    
    // create bluetooth emmiter
    self.bluetoothEmitter = [[DCBluetoothEmitter alloc] initWithService:serviceUUID
                                                         characteristic:characteristicUUID
                                                                  value:userUUID];

    // fetch avatar imahe
    [self updateAvatar];
}

#pragma mark -
#pragma mark Actions

- (IBAction)advertiseAction:(UISwitch *)sender {
    if (sender.isOn) {
        [self.bluetoothEmitter startAdvertisingService];
    } else {
        [self.bluetoothEmitter stopAdvertising];
    }
}

- (IBAction)updateAction:(id)sender {
    // hide keyboard
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
    // check connection
    MyService *service = [MyService sharedInstance];
    if (service.webSocket.readyState != SR_OPEN) return;

    // metadata payload
    NSDictionary *metadata = @{
        @"id": [[NSUUID alloc] initWithUUIDString:MyServiceExampleUserUUIDKey],
        @"name": self.nameTextField.text,
        @"email": self.emailTextField,
        @"avatar": [self avatarURLString]
    };
    
    // send update user metadata socket message
    [service sendMessage:[DCSocketService messageWithType:AUMessageTypeMetadataKey body:metadata]];
    
    // update avatar image view
    [self updateAvatar];
}

#pragma mark - 
#pragma mark Private

- (void)updateAvatar {
    // generate random avator image based on user name
    [self.imageView setImageWithURL:[NSURL URLWithString:[self avatarURLString]]];
}

- (IBAction)textFieldValueChangedAction:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] > 0;
}

- (NSString *)avatarURLString {
    return [NSString stringWithFormat:@"http://api.adorable.io/avatars/150/%@.png", self.nameTextField.text];
}

@end
