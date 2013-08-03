//
//  iCadeViewController.h
//  SNES4iOS
//
//  Created by Shawn Allen on 9/28/12.
//
//

#import <UIKit/UIKit.h>
#import "iCadeReaderView.h"
#import "ControlPadEventDelegate.h"

@interface iCadeViewController : UIViewController<iCadeEventDelegate>

@property (nonatomic, weak) IBOutlet id<ControlPadEventDelegate> delegate;

@end
