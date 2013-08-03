//
//  ControlPadEventDelegate.h
//  SNES4iOS
//
//  Created by Shawn Allen on 9/28/12.
//
//

#import <Foundation/Foundation.h>

typedef enum ControlPadState {
    ControlPadStateNone = 0x000,
    ControlPadStateUp = 0x001,
    ControlPadStateRight = 0x002,
    ControlPadStateDown = 0x004,
    ControlPadStateLeft = 0x008,
    
    ControlPadStateUpRight = ControlPadStateUp | ControlPadStateRight,
    ControlPadStateDownRight = ControlPadStateDown | ControlPadStateRight,
    ControlPadStateUpLeft = ControlPadStateUp | ControlPadStateLeft,
    ControlPadStateDownLeft = ControlPadStateDown | ControlPadStateLeft,
    
    ControlPadStateButtonA = 0x010,
    ControlPadStateButtonB = 0x020,
    ControlPadStateButtonC = 0x040,
    ControlPadStateButtonD = 0x080,
    ControlPadStateButtonE = 0x100,
    ControlPadStateButtonF = 0x200,
    ControlPadStateButtonG = 0x400,
    ControlPadStateButtonH = 0x800,
    
} ControlPadState;

@protocol ControlPadEventDelegate <NSObject>

@required
- (void)padChangedState:(ControlPadState)changedState pressed:(BOOL)pressed;

@end
