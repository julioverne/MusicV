#include <stdio.h>
#include <stdlib.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#include <sys/sysctl.h>
#import <substrate.h>
#import <CommonCrypto/CommonCrypto.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MPAVItem : NSObject
- (NSURL* )url;
@end



@interface UIViewController ()
- (UIImage* )artworkImage;
@end

@interface MusicNowPlayingViewController : UIViewController
{
	MPAVItem * _currentItem;
}
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, readonly) UIButton *dismissButton;
@property (nonatomic, readonly) UIView *titlesView;
@property (nonatomic, readonly) UIView *transportControls;
@property (nonatomic, readonly) UIView *secondaryTransportControls;

@property (nonatomic, readonly) UIView *playbackProgressSliderView;

@property (nonatomic, readonly) UIViewController *currentItemViewController;
@property (nonatomic, readonly) UIView *currentItemViewControllerBackgroundView;
@property (nonatomic, readonly) UIView *currentItemViewControllerContainerView;


-(void)updateTranport;
@end
