//
//  OSCDemoViewController.h
//  OSCDemo
//
//  Created by georg on 12/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

@class OSCManager, OSCInPort, OSCOutPort;
@class FliteTTS;

@interface OSCDemoViewController : UIViewController <UITextFieldDelegate> {
    //@interface OSCDemoViewController : UIViewController <UITextFieldDelegate, UIAccelerometerDelegate> {
	
    // put mutablearray of buttons here...
    
    //subviews under viewController
    
    //NSMutableArray *buttons;
  
	NSString *sendingToIP;
    NSString *myWifiIP;
	int sendingToPort;
	int receivingOnPort;
    int playerNumber;
    int changeState;
	
    BOOL toggleOscillator;
	BOOL slidingFlag;
    BOOL AMslidingFlag;
	UILabel *sliderLabel;
    UILabel *AMsliderLabel;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
	UILabel *sendingInfoLabel;
	UILabel *receivingInfoLabel;
    UILabel *receivingCharacter;
	UILabel *receivingDataLabel;
    
    UIButton *sendTextOscButton;
    UITextField *sendTextOsc;


    //TTS MOD
  //  UIButton *pitchUp;
  //  UIButton *pitchDown;
  //  UIButton *modUp;
  //  UIButton *modDown;
  //  UIButton *speedUp;
  //  UIButton *speedDown;
    
    //accelerometer x/y/z floating points
    //IBOutlet UILabel *xLabel;
    //IBOutlet UILabel *yLabel;
    //IBOutlet UILabel *zLabel;
    
    //UIAccelerometer *accelerometer;
    
    //UITextField *sendIPAddress;
    //UITextField *sendPortNumber;
    	
	OSCManager *manager;
	OSCInPort *inPort;
	OSCOutPort *outPort;
    
    CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
    
    FliteTTS *fliteEngine;
    
    //oscillator
    UILabel *frequencyLabel;
	UIButton *playButton;
	UISlider *frequencySlider;
    UISlider *AMSlider;
	AudioComponentInstance toneUnit;
    
@public
	double amplitude;
    double frequency;
    double AMfrequency;
	double sampleRate;
	double theta;
    double amp_theta;
}

- (void)sendOSCMessage:(float)floatMessage label:(NSString*)label;

- (void)sendOSCStringMessage:(NSString *)stringMessage label:(NSString*)label;

- (void)makeDynamicButton:(NSString *)buttonTitle buttonLeftMargin:(NSInteger)leftMargin buttonTopMargin:(NSInteger)topMargin buttonWidth:(NSInteger)width buttonHeight:(NSInteger)height buttonFunction:(NSString *)buttonFunction;

- (NSString *) getMyWifiIP;

@property(nonatomic, retain) UITextField *sendTextOsc;
@property(nonatomic, retain) UIButton *sendTextOscButton;

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

//oscillator
@property (nonatomic, retain) IBOutlet UISlider *frequencySlider;
@property (nonatomic, retain) IBOutlet UISlider *AMSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;

- (IBAction)sliderChanged:(UISlider *)frequencySlider;
- (IBAction)AMsliderChanged:(UISlider *)AMSlider;
//- (IBAction)togglePlay:(UIButton *)selectedButton;

- (IBAction)sendTextOscButtonPressed:(id) sender;
//- (void)togglePlay:(boolean_t)toggleOscillator;
//- (void)stop;

// added for reinitialization when application is brought forward

//- (IBAction) refresh:(id)sender;

//- (IBAction) playSystemSound: (id) sender;
//- (IBAction) playAlertSound: (id) sender;
//- (IBAction) vibrate: (id) sender;
//- (IBAction)   start:(id)sender;

@end

