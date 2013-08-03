//
//  iCadeViewController.m
//  SNES4iOS
//
//  Created by Shawn Allen on 9/28/12.
//
//

#import "iCadeViewController.h"

@interface iCadeViewController ()

@end

@implementation iCadeViewController

#pragma mark -
#pragma mark Class extension

- (void)mapChar:(char) chr {
    BOOL pressed = NO;
    int button = 0;
    switch (chr) {
        case 'w':
            button = ControlPadStateUp;
            pressed = YES;
            break;
        case 'e':
            button = ControlPadStateUp;
            pressed = NO;
            break;
        case 'd':
            button = ControlPadStateRight;
            pressed = YES;
            break;
        case 'c':
            button = ControlPadStateRight;
            pressed = NO;
            break;
        case 'x':
            button = ControlPadStateDown;
            pressed = YES;
            break;
        case 'z':
            button = ControlPadStateDown;
            pressed = NO;
            break;
        case 'a':
            button = ControlPadStateLeft;
            pressed = YES;
            break;
        case 'q':
            button = ControlPadStateLeft;
            pressed = NO;
            break;

        case 'y':
            button = ControlPadStateButtonA;
            pressed = YES;
            break;
        case 't':
            button = ControlPadStateButtonA;
            pressed = NO;
            break;

        case 'h':
            button = ControlPadStateButtonB;
            pressed = YES;
            break;
        case 'r':
            button = ControlPadStateButtonB;
            pressed = NO;
            break;

        case 'u':
            button = ControlPadStateButtonC;
            pressed = YES;
            break;
        case 'f':
            button = ControlPadStateButtonC;
            pressed = NO;
            break;

        case 'j':
            button = ControlPadStateButtonD;
            pressed = YES;
            break;
        case 'n':
            button = ControlPadStateButtonD;
            pressed = NO;
            break;

        case 'i':
            button = ControlPadStateButtonE;
            pressed = YES;
            break;
        case 'm':
            button = ControlPadStateButtonE;
            pressed = NO;
            break;

        case 'k':
            button = ControlPadStateButtonF;
            pressed = YES;
            break;
        case 'p':
            button = ControlPadStateButtonF;
            pressed = NO;
            break;
            
        case 'o':
            button = ControlPadStateButtonG;
            pressed = YES;
            break;
        case 'g':
            button = ControlPadStateButtonG;
            pressed = NO;
            break;

        case 'l':
            button = ControlPadStateButtonH;
            pressed = YES;
            break;
        case 'v':
            button = ControlPadStateButtonH;
            pressed = NO;
            break;
    
        
        default:
            break;
    }
    [[self delegate] padChangedState:button pressed:pressed];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    iCadeReaderView *control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [[self view] addSubview:control];
    [control setActive:YES];
    [control setDelegate:self];
}

#pragma mark -
#pragma mark iCadeEventDelegate

- (void)characterEntered:(char)chr {
    NSLog(@"character inserted VIEW: %d", chr);
    [self mapChar:chr];
}

@end
