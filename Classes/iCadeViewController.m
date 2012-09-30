//
//  iCadeViewController.m
//  SNES4iOS
//
//  Created by Shawn Allen on 9/28/12.
//
//

#import "iCadeViewController.h"

@interface iCadeViewController ()

- (void)setState:(BOOL)state forButton:(iCadeState)button;

@end

@implementation iCadeViewController

#pragma mark -
#pragma mark Class extension

- (void)setState:(BOOL)state forButton:(iCadeState)button;
{
    ControlPadState padButton = ControlPadStateNone;
    
    switch (button) {
        case iCadeButtonA:
            padButton = ControlPadStateButtonA;
            break;
        case iCadeButtonB:
            padButton = ControlPadStateButtonB;
            break;
        case iCadeButtonC:
            padButton = ControlPadStateButtonC;
            break;
        case iCadeButtonD:
            padButton = ControlPadStateButtonD;
            break;
        case iCadeButtonE:
            padButton = ControlPadStateButtonE;
            break;
        case iCadeButtonF:
            padButton = ControlPadStateButtonF;
            break;
        case iCadeButtonG:
            padButton = ControlPadStateButtonG;
            break;
        case iCadeButtonH:
            padButton = ControlPadStateButtonH;
            break;
        case iCadeJoystickUp:
            padButton = ControlPadStateUp;
            break;
        case iCadeJoystickRight:
            padButton = ControlPadStateRight;
            break;
        case iCadeJoystickDown:
            padButton = ControlPadStateDown;
            break;
        case iCadeJoystickLeft:
            padButton = ControlPadStateLeft;
            break;
        default:
            break;
    }
    
    [[self delegate] padChangedState:padButton pressed:state];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    iCadeReaderView *control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [[self view] addSubview:control];
    [control setActive:YES];
    [control setDelegate:self];
}

#pragma mark -
#pragma mark iCadeEventDelegate

- (void)buttonDown:(iCadeState)button;
{
    [self setState:YES forButton:button];
}

- (void)buttonUp:(iCadeState)button;
{
    [self setState:NO forButton:button];
}

@end
