//
//  AMBALogViewController.h
//  RemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"

@interface AMBALogViewController : UIViewController<UIAlertViewDelegate>
{
    IBOutlet    UITextView   *textView;
}
- (IBAction)closeLogView:(id)sender;

- (IBAction)moveToEnd:(id)sender;
- (IBAction)resetLog:(id)sender;

@end
