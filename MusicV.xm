#import "MusicV.h"
#import <QuartzCore/QuartzCore.h>

#define ALPHA_DEFAULT 1.0

static UIButton* musicList = nil;
static UIButton* musicLove = nil;
static UIButton* musicRand = nil;
static UIButton* musicPlay = nil;
static UIButton* musicMore = nil;
static UIButton* musicRepe = nil;


static UIImageView* artView = nil;
static UIImage* oldArtImage = nil;

static UIView* circleView = nil;

//static UIBezierPath* shadowPath = nil;

@interface UIButton (m)
-(UIColor*)regularColor;
@end


@implementation UIImage (m)
- (UIImage*) blur:(UIImage*)image
{
    CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *inputImage = [[CIImage alloc] initWithImage:image];
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputImage",inputImage,@"inputRadius",@8.0F,nil];
	CIImage * outputImage = filter.outputImage;
	CGImageRef cgImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
	UIImage* returnImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
    return returnImage;
}
- (UIImage *)imageWithSize:(CGSize)size
{
	if (NULL != &UIGraphicsBeginImageContextWithOptions) {
		UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	} else {
		UIGraphicsBeginImageContext(size);
	}
	UIImage *sel = (UIImage *)self;
	[sel drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end

%hook MusicNowPlayingViewController
- (id)transportControls
{
	UIView* ret = %orig;
	if(UIButton* viewNow = (UIButton*)[ret viewWithTag:7]) {
		musicList = viewNow;
		[musicList removeFromSuperview];
		[self.view addSubview:musicList];
	}
	if(UIButton* viewNow = (UIButton*)[ret viewWithTag:6]) {
		musicLove = viewNow;
		[musicLove removeFromSuperview];
		[self.view addSubview:musicLove];
	}	
	[[self secondaryTransportControls] layoutSubviews];
	if(UIButton* viewNow = (UIButton*)[self.secondaryTransportControls viewWithTag:10]) {
		musicRand = viewNow;
		[musicRand removeFromSuperview];
		[self.view addSubview:musicRand];
	}
	if(UIButton* viewNow = (UIButton*)[self.secondaryTransportControls viewWithTag:11]) {
		musicMore = viewNow;
		[musicMore removeFromSuperview];
		[self.view addSubview:musicMore];
	}
	if(UIButton* viewNow = (UIButton*)[self.secondaryTransportControls viewWithTag:9]) {
		musicRepe = viewNow;
		[musicRepe removeFromSuperview];
		[self.view addSubview:musicRepe];
	}
	if(UIButton* viewNow = (UIButton*)[ret viewWithTag:3]) {
		musicPlay = viewNow;
		if(viewNow.tag == 3) {
			if(UIView* oldRem = [viewNow viewWithTag:465]) {
				if(oldRem) {
					oldRem.center = viewNow.imageView.center;
					return ret;	
				}
			}
			int dotSize = musicPlay.frame.size.height*2.5;
			UIView* circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dotSize,dotSize)];
			circleView.center = musicPlay.imageView.center;
			circleView.tag = 465;
			circleView.alpha = 1.0;
			circleView.layer.cornerRadius = dotSize/2;
			circleView.backgroundColor = nil;
			circleView.layer.borderColor = [UIColor blackColor].CGColor;
			circleView.layer.borderWidth = 2/1.5;
			circleView.userInteractionEnabled = NO;
			[viewNow addSubview:circleView];
		}		
	}
	return ret;
}

-(void)viewDidLoad
{
	%orig;
	for(UIView*viewNow in self.view.subviews) {
		[viewNow removeFromSuperview];
	}
	for(UIView*viewNow in self.backgroundView.subviews) {
		[viewNow removeFromSuperview];
	}
	
	[self.view addSubview:self.backgroundView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	artView = [UIImageView new];
	artView.tag = 493;
	artView.frame =  CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height+15, self.view.frame.size.height+15);
	artView.center =  self.view.center;
	artView.contentMode = UIViewContentModeScaleAspectFill;	
	artView.backgroundColor = [UIColor whiteColor];
	artView.autoresizingMask = /*UIViewAutoresizingFlexibleWidth |*/ UIViewAutoresizingFlexibleHeight;
	artView.alpha = 0.7;
	artView.layer.shouldRasterize  = YES;
	
	[self.view addSubview:artView];
	
	/*UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurEffectView];*/
	
	[self.view addSubview:self.playbackProgressSliderView];
	
	[self.view addSubview:self.currentItemViewControllerContainerView];
	//self.currentItemViewControllerContainerView.layer.cornerRadius = 15;
	/*if(self.currentItemViewControllerContainerView) {
		shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((self.view.frame.size.width/6), (self.view.frame.size.width/6), self.view.frame.size.width/1.5, self.view.frame.size.width/1.5) cornerRadius:0];
		self.currentItemViewControllerContainerView.layer.shadowPath = shadowPath.CGPath;
		self.currentItemViewControllerContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
		self.currentItemViewControllerContainerView.layer.shadowOffset = CGSizeMake(1.5f, 1.5f);
		self.currentItemViewControllerContainerView.layer.shadowOpacity = 0.5f;
		if(self.dismissButton.alpha < 1) {
			self.currentItemViewControllerContainerView.layer.shadowOpacity = self.dismissButton.alpha;
		}
	}*/
	
	[self.view addSubview:self.titlesView];
	[self.view addSubview:self.dismissButton];
	[self.view addSubview:self.transportControls];
}

- (void)_playerPlaybackStateDidChangeNotification:(id)arg1
{
	%orig;
	if(artView) {
		UIImage* arkImg = [self.currentItemViewController artworkImage]?:[UIImage new];
		//if(UIImage* arkImg = [self.currentItemViewController artworkImage]) {
			if(oldArtImage != arkImg) {
				oldArtImage = arkImg;
				//[artView setImage:[arkImg imageWithSize:CGSizeMake(self.view.frame.size.height+15, self.view.frame.size.height+15)]];
				[artView setImage:[[UIImage new] blur:[arkImg imageWithSize:CGSizeMake(self.view.frame.size.height+15, self.view.frame.size.height+15)]]];
			}
		//}
		//artView.backgroundColor = [self.currentItemViewController artworkImage]!=nil?[UIColor clearColor]:[UIColor whiteColor];
	}
}
- (void)transportControlsViewDidLayoutSubviews:(id)arg1
{
	%orig;
	if(musicList) {
		musicList.frame = CGRectMake(musicList.frame.origin.x, self.dismissButton.frame.origin.y, musicList.frame.size.width, musicList.frame.size.height);
	}
	if(musicRepe) {
		musicRepe.frame = CGRectMake(self.view.frame.origin.x+(self.view.frame.size.width/20)-(musicRepe.imageView.frame.origin.x), self.currentItemViewControllerContainerView.frame.origin.y+(self.currentItemViewControllerContainerView.frame.size.height)-musicRepe.frame.size.height, musicRepe.frame.size.width, musicRepe.frame.size.height);
	}
	if(musicRand) {
		musicRand.frame = CGRectMake(self.currentItemViewControllerContainerView.frame.origin.x+self.currentItemViewControllerContainerView.frame.size.width-(musicRand.imageView.frame.origin.x)+(self.view.frame.size.width/20), self.currentItemViewControllerContainerView.frame.origin.y+(self.currentItemViewControllerContainerView.frame.size.height)-musicRand.frame.size.height, musicRand.frame.size.width, musicRand.frame.size.height);
	}	
	if(musicLove) {
		musicLove.frame = CGRectMake(self.view.frame.origin.x+(self.view.frame.size.width/20)-(musicLove.imageView.frame.origin.x), self.titlesView.frame.origin.y+(self.titlesView.frame.size.height/4), musicLove.frame.size.width, musicLove.frame.size.height);
	}
	if(musicMore) {
		musicMore.frame = CGRectMake(self.titlesView.frame.origin.x+self.titlesView.frame.size.width-(musicMore.imageView.frame.origin.x)+(self.view.frame.size.width/20), self.titlesView.frame.origin.y+(self.titlesView.frame.size.height/4), musicMore.frame.size.width, musicMore.frame.size.height);
	}
	
	if(musicPlay&&circleView) {
		circleView.center = musicPlay.imageView.center;
	}
	if(UIView* oldRem = [musicPlay viewWithTag:465]) {
		oldRem.layer.borderColor = [musicPlay regularColor].CGColor;
		[oldRem layoutIfNeeded];
	}
	
	[[self secondaryTransportControls] layoutIfNeeded];
	if(artView) {
		UIImage* arkImg = [self.currentItemViewController artworkImage]?:[UIImage new];
		//if(UIImage* arkImg = [self.currentItemViewController artworkImage]) {
			if(oldArtImage != arkImg) {
				oldArtImage = arkImg;
				//[artView setImage:[arkImg imageWithSize:CGSizeMake(self.view.frame.size.height+15, self.view.frame.size.height+15)]];
				[artView setImage:[[UIImage new] blur:[arkImg imageWithSize:CGSizeMake(self.view.frame.size.height+15, self.view.frame.size.height+15)]]];
			}
		//}
		//artView.backgroundColor = [self.currentItemViewController artworkImage]!=nil?[UIColor clearColor]:[UIColor whiteColor];
	}
	//self.currentItemViewControllerContainerView.layer.cornerRadius = 15;
	/*if(self.currentItemViewControllerContainerView) {
		shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.view.frame.size.width/1.5, self.view.frame.size.width/1.5) cornerRadius:0];
		self.currentItemViewControllerContainerView.layer.shadowPath = shadowPath.CGPath;
		self.currentItemViewControllerContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
		self.currentItemViewControllerContainerView.layer.shadowOffset = CGSizeMake(1.5f, 1.5f);
		self.currentItemViewControllerContainerView.layer.shadowOpacity = 0.5f;
		if(self.dismissButton.alpha < 1) {
			self.currentItemViewControllerContainerView.layer.shadowOpacity = self.dismissButton.alpha;
		}
	}*/
}
-(void)viewDidLayoutSubviews
{
	%orig;
	float yByAdding;
	yByAdding = (self.view.frame.size.width/6);
	self.currentItemViewControllerContainerView.frame = CGRectMake((self.view.frame.size.width/6), yByAdding, self.view.frame.size.width/1.5, self.view.frame.size.width/1.5);
	
	yByAdding += (self.currentItemViewControllerContainerView.frame.size.height)+(self.view.frame.size.width/20);
	
	self.titlesView.frame = CGRectMake((self.view.frame.size.width/8), yByAdding, self.titlesView.frame.size.width - (2*(self.view.frame.size.width/8)), self.titlesView.frame.size.height);
	
	yByAdding += (self.titlesView.frame.size.height)+(self.view.frame.size.width/20);
	
	self.playbackProgressSliderView.frame = CGRectMake((self.view.frame.size.width/10), yByAdding, self.playbackProgressSliderView.frame.size.width - (2*(self.view.frame.size.width/10)), self.playbackProgressSliderView.frame.size.height);
	
	yByAdding += (self.playbackProgressSliderView.frame.size.height);	
	
	self.transportControls.frame = CGRectMake(self.transportControls.frame.origin.x, yByAdding+((self.view.frame.size.height-yByAdding)/2)-self.transportControls.frame.size.height, self.transportControls.frame.size.width, self.transportControls.frame.size.height);
	
	if(musicList) {
		musicList.alpha = self.dismissButton.alpha;
	}
	if(musicLove) {
		musicLove.alpha = self.dismissButton.alpha;
	}
	if(musicRand) {
		musicRand.alpha = self.dismissButton.alpha;
	}
	if(musicMore) {
		musicMore.alpha = self.dismissButton.alpha;
	}
	if(musicRepe) {
		musicRepe.alpha = self.dismissButton.alpha;
	}
	
	if(self.dismissButton.alpha < 1) {
		self.currentItemViewControllerContainerView.layer.shadowOpacity = self.dismissButton.alpha;
	}
	
	//self.currentItemViewControllerContainerView.layer.cornerRadius = 15;
	
	if(musicPlay&&circleView) {
		circleView.center = musicPlay.imageView.center;
	}
	if(UIView* oldRem = [musicPlay viewWithTag:465]) {
		oldRem.layer.borderColor = [musicPlay regularColor].CGColor;
		[oldRem layoutIfNeeded];
	}
	
	
	self.titlesView.alpha = self.dismissButton.alpha;
	self.playbackProgressSliderView.alpha = self.dismissButton.alpha;
	self.transportControls.alpha = self.dismissButton.alpha;
	if(self.dismissButton.alpha > 0) {
		self.playbackProgressSliderView.alpha = ALPHA_DEFAULT;
		self.titlesView.alpha = ALPHA_DEFAULT;
		self.transportControls.alpha = ALPHA_DEFAULT;
	}	
}
%end
