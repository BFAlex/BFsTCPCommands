//
//  AMBALogViewController.m
//  RemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import "AMBALogViewController.h"

@interface AMBALogViewController ()

@end

@implementation AMBALogViewController


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
	// Do any additional setup after loading the view.
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:@"AmbaRemoteCam.txt"];
    NSFileManager   *manager = [NSFileManager defaultManager];
    NSLog(@"View Log File Path --------------->: %@",filePath);
    if ( [manager fileExistsAtPath:filePath]) {
        NSString *stringFromFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: nil];
        NSLog(@"View Log File Path --------------->:");
        textView.text = stringFromFile;
        //NSLog(@"-------List of Files in Documents Folder: %@",[manager contentsOfDirectoryAtPath:documentsDirectory
         //                                                                                  error:nil]);
                                                               
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(querySessionHolder:)
                                                 name:querySessionHolderNotification
                                               object:nil];

}

- (void) querySessionHolder: (NSNotification *)notificationParam
{
    if ([ ambaStateMachine getInstance].notificationCount ){
        
        UIAlertView *jsonDebugAlert = [[UIAlertView alloc] initWithTitle:@"Last Command Response:"
                                                                 message: [ambaStateMachine getInstance].notifyMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"RetainSession"
                                                       otherButtonTitles:@"logout", nil];
        [jsonDebugAlert show];
        
        [ ambaStateMachine getInstance].notificationCount = 0;
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //NSLog(@"#############CancelButton Was Activated");
        NSLog(@"LogOut button Selected");
    } else {
        [[ambaStateMachine getInstance ] keepSessionActive];
    }
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeLogView:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:NO
                                                      completion:nil];
    
}

- (IBAction)moveToEnd:(id)sender {
    CGPoint offset = CGPointMake(0,textView.contentSize.height - textView.frame.size.height);
    [textView setContentOffset:offset animated:YES];
//    [textView scrollRectToVisible:CGRectMake(0,0,textView.frame.size.width, textView.frame.size.height)
  //                       animated:YES];
}

- (IBAction)resetLog:(id)sender {
    [[ambaStateMachine getInstance] resetLogFile:@"AmbaRemoteCam.txt"];
    [self viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
   // [textView scrollRectToVisible:CGRectMake(0,0,textView.frame.size.width, textView.frame.size.height *4)
   //                      animated:YES];
    CGPoint offset = CGPointMake(0,(textView.contentSize.height - textView.frame.size.height));
    [textView setContentOffset:offset animated:NO];
}


@end
