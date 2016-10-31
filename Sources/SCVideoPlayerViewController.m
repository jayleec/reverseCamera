//
//  SCVideoPlayerViewController.m
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 8/30/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import "SCVideoPlayerViewController.h"
#import "SCEditVideoViewController.h"
#import "SCWatermarkOverlayView.h"
#import "AVUtilities.h"
#import "DTProgressView.h"
#import "SCAppDelegate.h"
#import "Product.h"

@import GoogleMobileAds;
@import UIKit;

@interface SCVideoPlayerViewController ()
//progress bar for reverse button


@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;
@property (assign) BOOL isChangedToBackwards;


@property(weak, nonatomic) UIViewController *fullAdController;
@property(nonatomic, strong) GADInterstitial *interstitial;


@end

@implementation SCVideoPlayerViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


//bring ad info from shop view


- (void)createAndLoadInterstitial {
    
        self.interstitial =
        [[GADInterstitial alloc] initWithAdUnitID:@"google ad mob id"];
    
        GADRequest *request = [GADRequest request];
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = @[ kGADSimulatorID, @"Test device id" ];
        [self.interstitial loadRequest:request];

}

-(void)showAd{

    if(_isPurchased > 0){
        return;
    }else{
        NSLog(@"show Ad");
        if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self.fullAdController];
        } else {
         NSLog(@"Ad wasn't ready");
         }
        [self createAndLoadInterstitial];
    }
    
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization
    }
	
    return self;
}

- (void)dealloc {
    [self.filterSwitcherView removeObserver:self forKeyPath:@"selectedFilter"];
    self.filterSwitcherView = nil;
    [_player pause];
    _player = nil;
    [self cancelSaveToCameraRoll];
}

- (SCFilter *)createAnimatedFilter {
    SCFilter *animatedFilter = [SCFilter emptyFilter];
    animatedFilter.name = @"Animated Filter";
    
    SCFilter *gaussian = [SCFilter filterWithCIFilterName:@"CIGaussianBlur"];
    SCFilter *blackAndWhite = [SCFilter filterWithCIFilterName:@"CIColorControls"];
    
    [animatedFilter addSubFilter:gaussian];
    [animatedFilter addSubFilter:blackAndWhite];
    
    double duration = 0.5;
    double currentTime = 0;
    BOOL isAscending = YES;
    
    Float64 assetDuration = CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration);
    
    while (currentTime < assetDuration) {
        if (isAscending) {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@1 endValue:@0 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@0 endValue:@10 startTime:currentTime duration:duration];
        } else {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@0 endValue:@1 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@10 endValue:@0 startTime:currentTime duration:duration];
        }
        
        currentTime += duration;
        isAscending = !isAscending;
    }
    
    return animatedFilter;
}

- (void)viewDidLoad
{
    
    self.fullAdView.alpha = 0;
    self.fullAdController.view.alpha = 0;
    self.fullAdController = [self.storyboard instantiateViewControllerWithIdentifier:@"fullAdView"];
    [self addChildViewController:self.fullAdController];
    [self.view addSubview:self.fullAdController.view];
    
    [super viewDidLoad];
    
    SCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Product *newObj = [fetchedObjects objectAtIndex:0];
    
    NSLog(@"\n\n fetch purchased:%@", newObj.purchased);
    if (fetchedObjects == nil) {
        // Handle the error.
    }else{
        _isPurchased = newObj.purchased;
        NSLog(@"\n\n _isPurchased:%d", _isPurchased);
    }

    [self createAndLoadInterstitial];

    
    //set reverse button progress bar
    self.exportView.clipsToBounds = YES;
    self.exportView.layer.cornerRadius = 20;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveToCameraRoll)];
    
	_player = [SCPlayer player];
    
    if ([[NSProcessInfo processInfo] activeProcessorCount] > 1) {
        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
        
        SCFilter *emptyFilter = [SCFilter emptyFilter];
        emptyFilter.name = @"#nofilter";
        
        self.filterSwitcherView.filters = @[
                                                 emptyFilter,
                                                 [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                                                 [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
                                                 [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                                                 [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                                 [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                                 // Adding a filter created using CoreImageShop
                                                 [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                                 [self createAnimatedFilter]
                                                 ];
        _player.SCImageView = self.filterSwitcherView;
        [self.filterSwitcherView addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        //SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player]; = [[SCVideoPlayerView alloc] initWithPlayer:_player];
        _playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
        _playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerView.frame = self.filterSwitcherView.frame;
        _playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
        [self.filterSwitcherView.superview insertSubview:_playerView aboveSubview:self.filterSwitcherView];
        [self.filterSwitcherView removeFromSuperview];
    }
    
	_player.loopEnabled = YES;
    _isSaved = false;
    
    
}





- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
	[_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.filterSwitcherView) {
        self.filterNameLabel.hidden = NO;
        self.filterNameLabel.text = self.filterSwitcherView.selectedFilter.name;
        self.filterNameLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.filterNameLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.filterNameLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCEditVideoViewController class]]) {
        SCEditVideoViewController *editVideo = segue.destinationViewController;
        editVideo.recordSession = self.recordSession;
    }
}

- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        CGRect frame =  self.progressView.frame;
        frame.size.width = self.progressView.superview.frame.size.width * progress;
        self.progressView.frame = frame;
    });
}

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)cancelTapped:(id)sender {
    [self cancelSaveToCameraRoll];
}

- (void)_addActionToAlertController:(UIAlertController *)alertController forType:(SCContextType)contextType withName:(NSString *)name {
    if ([SCContext supportsType:contextType]) {
        UIAlertActionStyle style = (self.filterSwitcherView.contextType != contextType ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive);
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:style handler:^(UIAlertAction * _Nonnull action) {
            self.filterSwitcherView.contextType = contextType;
        }];
        [alertController addAction:action];
    }
}

- (IBAction)changeRenderingModeTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change video rendering mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self _addActionToAlertController:alertController forType:SCContextTypeAuto withName:@"Auto"];
    [self _addActionToAlertController:alertController forType:SCContextTypeMetal withName:@"Metal"];
    [self _addActionToAlertController:alertController forType:SCContextTypeEAGL withName:@"EAGL"];
    [self _addActionToAlertController:alertController forType:SCContextTypeCoreGraphics withName:@"Core Graphics"];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}





- (void)saveToCameraRoll {
    
    if(_isChangedToBackwards == YES){
        AVAsset *originalAsset =self.recordSession.assetRepresentingSegments;
        [AVUtilities assetByReversingAsset:originalAsset outputURL:self.recordSession.outputUrl];
        
        self.exportView.hidden = NO;
        self.exportView.alpha = 0;
        CGRect frame =  self.progressView.frame;
        frame.size.width = 0;
        self.progressView.frame = frame;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        
        [UIView animateWithDuration:0.8 animations:^{
            self.exportView.alpha = 1;
        }];

        [UIView animateWithDuration:0.8 animations:^{
            self.exportView.alpha = 0;
        }];
        
        
        
        [self.recordSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if (error == nil) {
                [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [self showInstagramShare];
                [self showAd];
                
                
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }else{


    

    self.navigationItem.rightBarButtonItem.enabled = NO;
    SCFilter *currentFilter = [self.filterSwitcherView.selectedFilter copy];
    [_player pause];

    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;

    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    self.exportSession = exportSession;
    
    self.exportView.hidden = NO;
    self.exportView.alpha = 0;
    CGRect frame =  self.progressView.frame;
    frame.size.width = 0;
    self.progressView.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.exportView.alpha = 1;
    }];

    SCWatermarkOverlayView *overlay = [SCWatermarkOverlayView new];
    overlay.date = self.recordSession.date;
    exportSession.videoConfiguration.overlay = overlay;
    NSLog(@"Starting exporting");

    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    //////////////////
    

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;

        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }

        if (strongSelf != nil) {
            [strongSelf.player play];
            strongSelf.exportSession = nil;
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;

            [UIView animateWithDuration:0.3 animations:^{
                strongSelf.exportView.alpha = 0;
            }];
        }

        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            

            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                if (error == nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    
                    [self showInstagramShare];
                    [self showAd];
                    

                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    
                    [self showAd];
                }
            }];//endof exportSession
            

        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        
        
        
    }];
    

    }

}

-(void)showInstagramShare{
    
    //animation to show up
    CGRect viewFrame = self.shareInatagramView.frame;
    //get screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    viewFrame.origin.y = screenHeight/2;
   
    [UIView animateWithDuration:0.15 animations:^{
        self.shareInatagramView.frame = viewFrame;

    }];
    
    
    
}


//converting to playback backwards button
- (IBAction)playBack:(id)sender {
  
    NSLog(@"\n\n playBack pressed");
    
    //change to reversed
    AVAsset *originalAsset =self.recordSession.assetRepresentingSegments;
    AVAsset *reversedAsset =[AVUtilities assetByReversingAsset:originalAsset outputURL:self.recordSession.outputUrl];
    

    //playback asset
    _isChangedToBackwards = YES;
    [self.player setItemByAsset:reversedAsset];
    
}

- (IBAction)goOriginal:(id)sender {
    _isChangedToBackwards = NO;
    [self.player setItemByAsset:self.recordSession.assetRepresentingSegments];
}


- (IBAction)cancelInstagramShare:(id)sender {
    CGRect viewFrame = self.shareInatagramView.frame;
    
        viewFrame.origin.y = 1000;
   
    
    [UIView animateWithDuration:0.15 animations:^{
        self.shareInatagramView.frame = viewFrame;
        
    }];
    
}

- (IBAction)instagramOpen:(id)sender {
    
    //////////////////////INSTAGRAM SHARE
    NSLog(@"its instagram");
     NSURL *instagramURL = [NSURL URLWithString:@"instagram://tag?name=reversecamera"];
     if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
     [[UIApplication sharedApplication] openURL:instagramURL];
     }
     
}
@end
