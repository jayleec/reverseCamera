//
//  SCVideoPlayerViewController.h
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 8/30/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"




@interface SCVideoPlayerViewController : UIViewController<SCPlayerDelegate, SCAssetExportSessionDelegate>
- (IBAction)cancelInstagramShare:(id)sender;
- (IBAction)instagramOpen:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shareInatagramView;


@property (weak, nonatomic) IBOutlet UIView *fullAdView;
@property (strong, nonatomic) SCRecordSession *recordSession;
@property (strong, nonatomic) SCVideoPlayerView *playerView;
@property (assign) BOOL isSaved; //notify admob
@property (nonatomic) int isPurchased; //notify IAP purchased

@property (nonatomic, strong) UIPopoverController *popover; //instagram share

@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;
@property (weak, nonatomic) IBOutlet UIView *exportView;
@property (weak, nonatomic) IBOutlet UIView *progressView;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (IBAction)playBack:(id)sender;
- (IBAction)goOriginal:(id)sender;

@end
