//
//  ControlPadManager.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"
#import "ControlPadManager.h"
#import "ControlPadConnectViewController.h"
#import "RomDetailViewController.h"

#define MAX_CONNECTIONS 4
#define SESSION_ID @"com.snes-hd.controller"

unsigned long padStatusForPadNumber(int which)
{
	if (which < MAX_CONTROL_PADS)
		return [AppDelegate().controlPadManager statusForPadNumber:which];

	return 0;
}

@implementation ControlPadManager 
@synthesize padAwaitingConnection, pendingConnectionPeerID;


- (id) init
{
	if (self = [super init])
	{
        gkSession = [[GKSession alloc] initWithSessionID:SESSION_ID 
											 displayName:nil 
											 sessionMode:GKSessionModeServer];
		gkSession.delegate = self;
		[gkSession setDataReceiveHandler:self withContext:NULL];
		controlPadPeerIDs = [[NSMutableArray alloc] initWithObjects:
							 [NSMutableString string],
							 [NSMutableString string],
							 [NSMutableString string],
							 [NSMutableString string],
							 nil];

	}
	return self;
}

- (void) searchForConnectionToPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return;
	
	padAwaitingConnection = padNumber;
	gkSession.available = YES;
}

- (void) stopSearchingForConnection
{
    padAwaitingConnection = 0;
	gkSession.available = NO;
}

- (NSString *) deviceNameForPendingConnection
{
	return [gkSession displayNameForPeer:pendingConnectionPeerID];
}

- (NSString *) deviceNameForPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return nil;
	
	return [gkSession displayNameForPeer: [controlPadPeerIDs objectAtIndex:padNumber]];
}

- (unsigned long) statusForPadNumber:(NSUInteger)padNumber
{
	if (padNumber < MAX_CONTROL_PADS) {
		return padStatus[padNumber];
	}
	return 0;
}

- (void) disconnectPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return;
	
	NSString *peerID = [controlPadPeerIDs objectAtIndex:padNumber];
	[gkSession disconnectPeerFromAllPeers:peerID];
	[[controlPadPeerIDs objectAtIndex:padNumber] setString:@""];
}

- (void) disconnectPeer:(NSString *)peerID
{
	if ([controlPadPeerIDs containsObject:peerID])
	{
		[self disconnectPadNumber:[controlPadPeerIDs indexOfObject:peerID]];
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	if (![controlPadPeerIDs containsObject:peer])
		return;
	
	NSUInteger padNumber = [controlPadPeerIDs indexOfObject:peer];
    [self convertData:data padNumber:padNumber];
    
	NSLog(@"recieved pad status for player %d: %lX", padNumber + 1, padStatus[padNumber]);
}

- (void)convertData:(NSData *)data padNumber:(NSUInteger)padNumber {
    
	[data getBytes:&padStatus[padNumber]];
}

- (void) acceptPendingConnection
{
	[gkSession acceptConnectionFromPeer:self.pendingConnectionPeerID error:nil];
	[[controlPadPeerIDs objectAtIndex:padAwaitingConnection] setString:self.pendingConnectionPeerID];
	self.pendingConnectionPeerID = nil;

	[[AppDelegate() romDetailViewController] updateConnectionButtons];
}

- (void) denyPendingConnection
{
	[gkSession denyConnectionFromPeer:self.pendingConnectionPeerID];
	self.pendingConnectionPeerID = nil;
}

#pragma mark -
#pragma mark ControlPadEventDelegate
enum  { GP2X_UP=0x1,       GP2X_LEFT=0x4,       GP2X_DOWN=0x10,  GP2X_RIGHT=0x40,
	GP2X_START=1<<8,   GP2X_SELECT=1<<9,    GP2X_L=1<<10,    GP2X_R=1<<11,
	GP2X_A=1<<12,      GP2X_B=1<<13,        GP2X_X=1<<14,    GP2X_Y=1<<15,
	GP2X_VOL_UP=1<<23, GP2X_VOL_DOWN=1<<22, GP2X_PUSH=1<<27 };

- (void)padChangedState:(ControlPadState)changedState pressed:(BOOL)pressed;
{
    static unsigned long padState = 0;
    
    unsigned long stateInGP2XValue = 0;
    
    /*
     A        SELECT
     B        LEFT SHOULDER
     C        START
     D        RIGHT SHOULDER
     E        Y
     F        A
     G        B
     H        X
     */
    
    switch (changedState) {
        case ControlPadStateNone:
            stateInGP2XValue = 0;
            break;
        case ControlPadStateUp:
            stateInGP2XValue = GP2X_UP;
            NSLog(@"UP p=%d", pressed);
            break;
        case ControlPadStateDown:
            stateInGP2XValue = GP2X_DOWN;
            NSLog(@"DOWN p=%d", pressed);
            break;
        case ControlPadStateLeft:
            stateInGP2XValue = GP2X_LEFT;
            break;
        case ControlPadStateRight:
            stateInGP2XValue = GP2X_RIGHT;
            break;
        case ControlPadStateButtonA:
            stateInGP2XValue = GP2X_SELECT;
            break;
        case ControlPadStateButtonB:
            stateInGP2XValue = GP2X_L;
            break;
        case ControlPadStateButtonC:
            stateInGP2XValue = GP2X_START;
            break;
        case ControlPadStateButtonD:
            stateInGP2XValue = GP2X_R;
            break;
        case ControlPadStateButtonE:
            stateInGP2XValue = GP2X_Y;
            break;
        case ControlPadStateButtonF:
            stateInGP2XValue = GP2X_A;
            break;
        case ControlPadStateButtonG:
            stateInGP2XValue = GP2X_B;
            break;
        case ControlPadStateButtonH:
            stateInGP2XValue = GP2X_X;
            break;
        case ControlPadStateDownLeft:
        case ControlPadStateDownRight:
        case ControlPadStateUpLeft:
        case ControlPadStateUpRight:
        default:
            NSLog(@"%s Compound pad movement sent, but was unhandled.", __PRETTY_FUNCTION__);
            break;
    }
    
    if (pressed)
        padState |= stateInGP2XValue;
    else
        padState ^= stateInGP2XValue;
    
    [self convertData:[NSData dataWithBytes:&padState length:sizeof(padState)] padNumber:0];
}

#pragma mark -
#pragma mark GKSession Delegate methods
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"Session state changed");
	
	switch (state) {
		case GKPeerStateConnected:
			NSLog(@"New Peer connected: %@", peerID);
			[[controlPadPeerIDs objectAtIndex:padAwaitingConnection] setString:peerID];
			self.pendingConnectionPeerID = nil;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateConnected;
			
			break;
		case GKPeerStateAvailable:
		case GKPeerStateConnecting:
			NSLog(@"Peer connecting/available: %@", peerID);
			self.pendingConnectionPeerID = peerID;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateAvailable;
			break;
		case GKPeerStateUnavailable:
			NSLog(@"Peer unavailable: %@", peerID);
			self.pendingConnectionPeerID = nil;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateSearching;
			break;
		case GKPeerStateDisconnected:
			NSLog(@"Peer disconnected: %@", peerID);
			[self disconnectPeer:peerID];
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateSearching;
			[AppDelegate().romDetailViewController updateConnectionButtons];
			break;
			
		default:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSLog(@"Recieved connection request from %@", peerID);
	self.pendingConnectionPeerID = peerID;
	AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateAvailable;
}
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"Connection with %@ failed", peerID);
}
@end
