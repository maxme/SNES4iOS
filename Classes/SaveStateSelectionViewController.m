//
//  SaveStateSelectionViewController.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"
#import "SaveStateSelectionViewController.h"
#import "src/snes4iphone_src/snapshot.h"
#import <UIKit/UITableView.h>

@implementation SaveStateSelectionViewController

@synthesize romFilter, selectedSavePath, selectedScreenshotPath, saveTableView, editButton, cancelButton, saveFiles, isModal;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	if(self.presentingViewController == nil) {
		NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
		[toolbarItems removeObject:cancelButton];
		[self setToolbarItems:toolbarItems];
	}
	self.saveTableView.rowHeight *= 2;
    self.saveFiles = [[NSMutableArray alloc] init];
	[self scanSaveDirectory];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotate {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void) scanSaveDirectory
{
	if (!self.romFilter) {
		return;
	}
	
	NSMutableArray *saveArray = [[NSMutableArray alloc] init];
	NSString *saveDir;
	NSString *path = AppDelegate().saveDirectoryPath;
	
	if([[path substringWithRange:NSMakeRange([path length]-1,1)] compare:@"/"] == NSOrderedSame)
	{
		saveDir = path;
	}
	else
	{
		saveDir = [path stringByAppendingString:@"/"];
	}
	
	int i;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray* dirContents = [fileManager contentsOfDirectoryAtPath:saveDir error:nil];
	NSInteger entries = [dirContents count];
	
	for ( i = 0; i < entries; i++ )
	{
		if([[dirContents  objectAtIndex: i] length] < 3 ||
		   [[[dirContents  objectAtIndex: i] substringWithRange:NSMakeRange([[dirContents  objectAtIndex: i] length]-3,3)] caseInsensitiveCompare:@".sv"] != NSOrderedSame)
		{
			// Do nothing currently.
		}
		else
			if([[dirContents objectAtIndex:i] length] >= [romFilter length])
				if([[[dirContents objectAtIndex:i] substringToIndex:[romFilter length]] caseInsensitiveCompare:romFilter] == NSOrderedSame) {
					NSString* objectTitle = [dirContents  objectAtIndex: i ];
					[saveArray addObject:objectTitle];
				}
	}
	
	// sort the array by decending filename (reverse chronological order, since the date is in the filename)
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"description" ascending:NO];
	self.saveFiles = [saveArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
	
	[self.saveTableView reloadData];
    
}

- (IBAction) buttonPressed:(id)sender
{
	if (sender == cancelButton) {
		[((SNES4iOSAppDelegate *)[[UIApplication sharedApplication] delegate]).emulationViewController resume];
		[self dismissModalViewControllerAnimated:YES];
	}
	if (sender == editButton)
	{
		if (saveTableView.editing)
		{
			editButton.title = @"Edit";
			[saveTableView setEditing:NO animated:YES];
		} else {
			editButton.title = @"Done";
			[saveTableView setEditing:YES animated:YES];
		}
	}
}

- (void) deleteSaveAtIndex:(NSUInteger)saveIndex
{
	NSString *savePath = [[AppDelegate() saveDirectoryPath] stringByAppendingPathComponent:
						  [self.saveFiles objectAtIndex:saveIndex]];
	NSString *screenshotPath = [savePath stringByAppendingPathExtension:@"png"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	if ([fileManager fileExistsAtPath:savePath]) {
		[fileManager removeItemAtPath:savePath error:&error];
	}
	if ([fileManager fileExistsAtPath:screenshotPath]) {
		[fileManager removeItemAtPath:screenshotPath error:&error];
	}
	
	if (!error) {
		NSMutableArray *mutableSaves = [self.saveFiles mutableCopy];

		[mutableSaves removeObjectAtIndex:saveIndex];
		self.saveFiles = [[NSArray alloc] initWithArray:mutableSaves];
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:saveIndex inSection:0];
		[saveTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([self.saveFiles count] <= 0)
	{
		return 0;
	}
	
	return [self.saveFiles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *reuseIdentifier = @"labelCell";
	UITableViewCell*      cell;	

	cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) 
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 9.0f;
		cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;				
	
	if([self.saveFiles count] <= 0)
	{
		cell.textLabel.text = @"";
		return cell;
	}
	
	NSString *saveName = [self.saveFiles objectAtIndex:indexPath.row];
	
	//Make a date string out of saveName
	NSString *dateString = [saveName substringFromIndex:[self.romFilter length]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"'-'yyMMdd-HHmmss'.sv'"];
	NSDate *saveDate = [dateFormatter dateFromString:dateString];
	[dateFormatter setDateFormat:@"EEE',' MMM d',' yyyy '\n'h:mm:ss a"];
	cell.textLabel.text = [dateFormatter stringFromDate:saveDate];
	
	//If the format doesn't look like a date, just list it as its filename  
	if(cell.textLabel.text == nil)
		cell.textLabel.text = [self.saveFiles objectAtIndex:indexPath.row];
	
	//Set up the screenshot for the savestate
	NSString *imagePathString = [NSString stringWithFormat:@"%@/%@%@",AppDelegate().saveDirectoryPath,saveName,@".png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePathString];
	cell.imageView.image = image;
	
	// Set up the cell
	return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self deleteSaveAtIndex:indexPath.row];
	}   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self.saveFiles count] <= 0)
	{
		return;
	}
	
	NSString *listingsPath = AppDelegate().saveDirectoryPath;
	NSString *saveFile = [self.saveFiles objectAtIndex:indexPath.row];
	NSString *savePath = [listingsPath stringByAppendingPathComponent:saveFile];
	
#warning needs to be tested on iPad
	//This means that the view is being presented modally, and should unfreeze during emulation
	if(self.presentingViewController != nil) {
		S9xUnfreezeGame([savePath cStringUsingEncoding:NSStringEncodingConversionAllowLossy]); //Unfreeze!!
		
		//Resume emulation
		[self dismissModalViewControllerAnimated:YES];
		[((SNES4iOSAppDelegate *)[[UIApplication sharedApplication] delegate]).emulationViewController resume];
	}
	else { //We are using the load button on the iPad
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *screenshotFile = [saveFile stringByAppendingPathExtension:@"png"];
		NSString *screenshotPath = [AppDelegate().saveDirectoryPath stringByAppendingPathComponent:screenshotFile];
		
		[self willChangeValueForKey:@"selectedScreenshotPath"];
		if (selectedScreenshotPath)
		{
			selectedScreenshotPath = nil;
		}
		
		NSLog(@"Looking for screenshot at %@", screenshotPath);
		if ([fileManager fileExistsAtPath:screenshotPath])
		{
			NSLog(@"Found screenshot at %@", screenshotPath);
			selectedScreenshotPath = screenshotPath;
		}
		[self didChangeValueForKey:@"selectedScreenshotPath"];
		
		
		[self willChangeValueForKey:@"selectedSavePath"];
		selectedSavePath = savePath;
		[self didChangeValueForKey:@"selectedSavePath"];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

