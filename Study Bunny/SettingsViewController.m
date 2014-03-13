//
//  SettingsViewController.m
//  Study Bunny
//
//  Created by Dylan Hurd on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    // Nav bar
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    [self.navigationController.navigationBar setTintColor:MAINCOLOR];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    
    //adding the subview
    [self setView:[[SettingsView alloc] initWithFrame:[self.view bounds]]];
    
    
    [self.view.logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logout
{
    [PFUser logOut]; // Log out
    
    // Return to login page
    [self.delegate didLogout];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
