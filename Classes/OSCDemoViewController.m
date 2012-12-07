//
//  OSCDemoViewController.m
//  OSCDemo
//
//  Created by georg on 12/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "OSCDemoViewController.h"
//oscillatorx
#import <AudioToolbox/AudioToolbox.h>
//tts
#import "VVOSC.h"
#import "FliteTTS.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

//start oscillator math-stuff
/*
OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	//const double amplitude = 0.25;
    
	// Get the tone parameters out of the view controller
	OSCDemoViewController *viewController = (__bridge OSCDemoViewController *)inRefCon;
	double theta = viewController->theta;
    double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    
    double amp_theta = viewController->amp_theta;
    double amp_theta_increment = 2.0 * M_PI * viewController->AMfrequency / viewController->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * sin(amp_theta) * viewController->amplitude;
        amp_theta += amp_theta_increment;
        if (amp_theta > 2.0 * M_PI)
		{
			amp_theta -= 2.0 * M_PI;
        }
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
        }
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;
    viewController->amp_theta = amp_theta;
    
	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	OSCDemoViewController *viewController =
    (__bridge OSCDemoViewController *)inClientData;
	
	[viewController stop];
}
*/
//end oscillator mathystuff

@implementation OSCDemoViewController

@synthesize sendTextOsc, sendTextOscButton; //, pitchUp, pitchDown, modUp, modDown, speedUp, speedDown;
//when making interface dynamically, do not declare in header and synthesize...
@synthesize soundFileURLRef;
@synthesize soundFileObject;

//oscillator
@synthesize frequencySlider;
@synthesize AMSlider;
@synthesize playButton;
@synthesize frequencyLabel;

- (void)viewDidLoad {
    
    [self loadView];
    
    //send local IP address to computer when iOS app loads
    playerNumber = 0;
    
    //make this only happen the first time, when brain sends out IP... and during PINGS
    // [self sendOSCStringMessage:[NSString stringWithFormat:@"%@", [self getMyWifiIP]] label:[NSString stringWithFormat:@"/ip/"]];
    
    //oscillator
    //[self sliderChanged:frequencySlider];
    
    myWifiIP = @"255.255.255.255";
    sendingToIP = @"192.168.0.7";

#ifdef FUCKBUBBLE
	amplitude = 0.0;
    sampleRate = 44100;
    frequency = 440.0;
    AMfrequency = 0.0;
    
    changeState = 0;
    
    //assign buttons to new array alloc[init]
    //buttons = [[NSMutableArray alloc] init];
    
	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
	AudioSessionSetActive(true);
#endif
    
    
    //end oscillator
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
    
    
    // OSC
    manager = [[OSCManager alloc] init];
    [manager setDelegate:self];
    
    // receiving
	receivingOnPort = 9000;
	inPort = [manager createNewInputForPort:receivingOnPort];
    
    //sending
    sendingToPort = 8000;
    
    //Accelerometer declaration
    //accelerometer = [UIAccelerometer sharedAccelerometer];
    //accelerometer.updateInterval = 0.75;
    //accelerometer.delegate = self;
    
    
    // FLITE TTS
    fliteEngine = [[FliteTTS alloc] init];
    
	// VIEW
    
    //print OSC messages
	
	receivingDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 100)];
	receivingDataLabel.text = @"send osc from computer";
    receivingDataLabel.font = [UIFont boldSystemFontOfSize:17];
	receivingDataLabel.textAlignment = NSTextAlignmentCenter;
    receivingDataLabel.numberOfLines = 0; //will wrap text in new line
  //  [receivingDataLabel sizeToFit];
	[self.view addSubview:receivingDataLabel];
	//[receivingDataLabel release];
    
	
    //Background view
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.userInteractionEnabled = YES;
    
    
    //print local ip address and port number
    /*
     receivingInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 72, 280, 20)];
     receivingInfoLabel.text = [NSString stringWithFormat:@"%@:%i", [self getMyWifiIP], receivingOnPort];
     receivingInfoLabel.textColor = [UIColor grayColor];
     receivingInfoLabel.textAlignment = NSTextAlignmentCenter;
     [self.view addSubview:receivingInfoLabel];
     [receivingInfoLabel release];
     */
    //print character number
    
    /* receivingCharacter = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 280, 20)];
     receivingCharacter.text = [NSString stringWithFormat:@"Character Number %i", playerNumber];
     receivingCharacter.font = [UIFont boldSystemFontOfSize:17];
     receivingCharacter.textAlignment = NSTextAlignmentCenter;
     [self.view addSubview:receivingCharacter];
     [receivingCharacter release];*/
    
    //send text through OSC
    
    sendTextOsc = [[UITextField alloc] initWithFrame:CGRectMake(20, 62, 280, 30)];
    sendTextOsc.borderStyle = UITextBorderStyleRoundedRect;
    sendTextOsc.textColor = [UIColor blackColor];
    sendTextOsc.font = [UIFont systemFontOfSize:17.0];
    sendTextOsc.placeholder = @"Write Text To All";  //place holder
    sendTextOsc.backgroundColor = [UIColor whiteColor];
    sendTextOsc.autocorrectionType = UITextAutocorrectionTypeNo;
    sendTextOsc.backgroundColor = [UIColor clearColor];
    sendTextOsc.keyboardType = UIKeyboardTypeDefault;
    sendTextOsc.returnKeyType = UIReturnKeyDone;
    sendTextOsc.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:sendTextOsc];
    sendTextOsc.delegate = self;
    
    //send text OSC button
    
    sendTextOscButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendTextOscButton addTarget:self
                          action:@selector(sendTextOscButtonPressed:)
                forControlEvents:UIControlEventTouchDown];
    [sendTextOscButton setTitle:@"Send Text To All" forState:UIControlStateNormal];
    sendTextOscButton.frame = CGRectMake(20, 102, 280, 40);
    [self.view addSubview:sendTextOscButton];
    
    //SLIDER
    
	UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 232, 280, 20)];
	
	[slider addTarget:self action:@selector(slidingStarted:) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(slidingEndedInside:) forControlEvents:UIControlEventTouchUpInside];
	[slider addTarget:self action:@selector(slidingDrag:) forControlEvents:UIControlEventTouchDragInside];
	[slider addTarget:self action:@selector(slidingDrag:) forControlEvents:UIControlEventTouchDragOutside];
	
	slider.minimumValue = 0.0;
	slider.maximumValue = 100.0;
	slider.continuous = YES;
	slider.value = 50.0;
	
	[self.view addSubview:slider];
	//[slider release];
	
    //Slider label
    
	sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 257, 280, 20)];
	sliderLabel.text = @"Frequency";
	sliderLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:sliderLabel];
	//[sliderLabel release];
    
    // AM Slider
    
    UISlider *AMslider = [[UISlider alloc] initWithFrame:CGRectMake(20, 282, 280, 20)];
	
	[AMslider addTarget:self action:@selector(AMslidingStarted:) forControlEvents:UIControlEventTouchDown];
	[AMslider addTarget:self action:@selector(AMslidingEndedInside:) forControlEvents:UIControlEventTouchUpInside];
	[AMslider addTarget:self action:@selector(AMslidingDrag:) forControlEvents:UIControlEventTouchDragInside];
	[AMslider addTarget:self action:@selector(AMslidingDrag:) forControlEvents:UIControlEventTouchDragOutside];
	
	AMslider.minimumValue = 0.0;
	AMslider.maximumValue = 100.0;
	AMslider.continuous = YES;
	AMslider.value = 50.0;
	
	[self.view addSubview:AMslider];
	//[AMslider release];
	
    //Slider label
    
	AMsliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 307, 280, 20)];
	AMsliderLabel.text = @"Mod Frequency";
	AMsliderLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:AMsliderLabel];
	//[AMsliderLabel release];
    
    //TTS MOD
    /*
     pitchUp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [pitchUp addTarget:self action:@selector(pitchUpPressed:)
     forControlEvents:UIControlEventTouchDown];
     [pitchUp setTitle:@"pitch up" forState:UIControlStateNormal];
     pitchUp.frame = CGRectMake(20, 150, 91, 35);
     [self.view addSubview:pitchUp];
     
     pitchDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [pitchDown addTarget:self action:@selector(pitchDownPressed:)
     forControlEvents:UIControlEventTouchDown];
     [pitchDown setTitle:@"pitch down" forState:UIControlStateNormal];
     pitchDown.frame = CGRectMake(20, 190, 91, 35);
     [self.view addSubview:pitchDown];
     
     modUp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [modUp addTarget:self action:@selector(modUpPressed:)
     forControlEvents:UIControlEventTouchDown];
     [modUp setTitle:@"mod up" forState:UIControlStateNormal];
     modUp.frame = CGRectMake(116, 150, 85, 35);
     [self.view addSubview:modUp];
     
     modDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [modDown addTarget:self action:@selector(modDownPressed:)
     forControlEvents:UIControlEventTouchDown];
     [modDown setTitle:@"mod down" forState:UIControlStateNormal];
     modDown.frame = CGRectMake(116, 190, 85, 35);
     [self.view addSubview:modDown];
     
     speedUp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [speedUp addTarget:self action:@selector(speedUpPressed:)
     forControlEvents:UIControlEventTouchDown];
     [speedUp setTitle:@"speed up" forState:UIControlStateNormal];
     speedUp.frame = CGRectMake(206, 150, 93, 35);
     [self.view addSubview:speedUp];
     
     speedDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [speedDown addTarget:self action:@selector(speedDownPressed:)
     forControlEvents:UIControlEventTouchDown];
     [speedDown setTitle:@"speed down" forState:UIControlStateNormal];
     speedDown.frame = CGRectMake(206, 190, 93, 35);
     [self.view addSubview:speedDown];
     */
    
    // title Label
	
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 372, 280, 42)];
	titleLabel.text = [NSString stringWithFormat:@"M.T.BRAIN"];
	titleLabel.textColor = [UIColor purpleColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:42];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
	//[titleLabel release];
    
	// subtitle Label
	
	subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 418, 280, 32)];
	subtitleLabel.text = [NSString stringWithFormat:@"Performgramming Node"];
	subtitleLabel.textColor = [UIColor redColor];
    subtitleLabel.font = [UIFont boldSystemFontOfSize:24];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:subtitleLabel];
    //	[subtitleLabel release];
    
    
}

- (void) slidingStarted:(UISlider*)slider {
	slidingFlag = YES;
}

- (void) slidingEndedInside:(UISlider*)slider {
	if (slidingFlag) {
		slidingFlag = NO;
        [self sendOSCMessage:slider.value label:@"/slider"];
	}
}

- (void) slidingDrag:(UISlider*)slider {
    [self sendOSCMessage:slider.value label:@"/slider"];
}

- (void) AMslidingStarted:(UISlider*)slider {
	AMslidingFlag = YES;
}

- (void) AMslidingEndedInside:(UISlider*)slider {
	if (AMslidingFlag) {
		AMslidingFlag = NO;
        [self sendOSCMessage:slider.value label:@"/amslider"];
	}
}

- (void) AMslidingDrag:(UISlider*)slider {
    [self sendOSCMessage:slider.value label:@"/amslider"];}

/*
 - (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration
 {
 [self sendOSCStringMessage:[NSString stringWithFormat:@"%f", acceleration.x] label:[NSString stringWithFormat:@"/%i/x-accel/", playerNumber]];
 [self sendOSCStringMessage:[NSString stringWithFormat:@"%f", acceleration.y] label:[NSString stringWithFormat:@"/%i/y-accel/", playerNumber]];
 [self sendOSCStringMessage:[NSString stringWithFormat:@"%f", acceleration.z] label:[NSString stringWithFormat:@"/%i/z-accel/", playerNumber]];
 }
 */
-(IBAction) sendTextOscButtonPressed:(id) sender{
    NSString *txt;
    txt = sendTextOsc.text;
    [self sendOSCStringMessage:txt label:@"/textOsc"];
}

-(IBAction) pitchUp:(id) sender{
    [self sendOSCMessage:1 label:[NSString stringWithFormat:@"/ttsPitch"]];
}
-(IBAction) pitchDown:(id) sender{
    [self sendOSCMessage:-1 label:[NSString stringWithFormat:@"/ttsPitch"]];
}
-(IBAction) modUp:(id) sender{
    [self sendOSCMessage:1 label:[NSString stringWithFormat:@"/ttsMod"]];
}
-(IBAction) modDown:(id) sender{
    [self sendOSCMessage:-1 label:[NSString stringWithFormat:@"/ttsMod"]];
}
-(IBAction) speedUp:(id) sender{
    [self sendOSCMessage:1 label:[NSString stringWithFormat:@"/ttsSpeed"]];
}
-(IBAction) speedDown:(id) sender{
    [self sendOSCMessage:-1 label:[NSString stringWithFormat:@"/ttsSpeed"]];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// called by delegate on message
- (void) receivedOSCMessage:(OSCMessage *)m	{
	
	NSString *address = [m address];
	OSCValue *value = [m value];
    NSMutableArray *valueArray = [m valueArray];
	NSString *message;
    NSString *txt;
    NSMutableString *tempTxt = [NSMutableString string];
    for(int i=0; i< [valueArray count]; i++)
    {
        [tempTxt appendString:[NSString stringWithFormat:@" %@", valueArray[i]]];
    }
  //  txt = tempTxt;
    /*
     [fliteEngine speakText:@"It works."];	// Make it talk
     [fliteEngine setPitch:100.0 variance:50.0 speed:1.0];	// Change the voice properties
     [fliteEngine setVoice:@"cmu_us_awb"];	// Switch to a different voice
     [fliteEngine stopTalking];				// stop talking
     
     * INCLUDED VOICES (you can remove the ones you don't need)
     
     cmu_us_kal
     cmu_us_kal16
     cmu_us_awb
     cmu_us_rms
     cmu_us_slt
     */
    
    
//    NSURL *MTBrain   = [[NSBundle mainBundle] URLForResource: @"MTBrain" withExtension: @"wav"];
    
    // Store the URL as a CFURLRef instance
    //self.soundFileURLRef = (CFURLRef) [tapSound retain];
    //self.soundFileURLRef = (CFURLRef) [boingSound retain];
    
    // Create a system sound object representing the sound file.
    //AudioServicesCreateSystemSoundID (
    //                                  soundFileURLRef,
    //                                  &soundFileObject
    //                                  );
    if ([address isEqualToString:@"/brainIP"]) {
       // txt = sendingToIP;
         //sendingToIP = [NSString stringWithFormat:@"%@", [value stringValue]];
        //outPort = [manager createNewOutputToAddress:sendingToIP atPort:sendingToPort];
        //myWifiIP = [NSString stringWithFormat:@"%@", [self getMyWifiIP]];
       // [self sendOSCIPMessage:myWifiIP label:[NSString stringWithFormat:@"/ip"]];
        txt = [NSString stringWithFormat:@"%@", [value stringValue]]; //sendingToIP;
    }
	else if ([address isEqualToString:@"/ints"]) {
        
        //switch (value intValue) { case 0: do this; break;
        //
#ifdef FUCKBUBBLE
		message = [NSString stringWithFormat:@"%i", [value intValue]];
        if ([value intValue] == 0) { AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            txt = [NSString stringWithFormat:@"Vibrate"];}
        if ([value intValue] == 1) {
            self.soundFileURLRef = (__bridge CFURLRef) MTBrain;
            AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
            AudioServicesPlaySystemSound (soundFileObject);
            txt = [NSString stringWithFormat:@"text: M.T.Brain"];}
#endif
	} else if ([address isEqualToString:@"/ping"]) {
        myWifiIP = [NSString stringWithFormat:@"%@", [self getMyWifiIP]];
        txt = [NSString stringWithFormat:@"ping from %@", [self getMyWifiIP]];
        [self sendOSCStringMessage:[NSString stringWithFormat:@"%i", playerNumber] label:@"/pingBack/"];
    } else if ([address isEqualToString:@"/floats"]) {
		message = [NSString stringWithFormat:@"%f", [value floatValue]];
        txt = [NSString stringWithFormat:@"%f", [value floatValue]];
    }
    else if ([address isEqualToString:@"/setCharacter"]) {
        playerNumber = [value intValue];
        txt = [NSString stringWithFormat:@"Player Number %i", playerNumber];
    }
    else if ([address isEqualToString:@"/ampOscillator"]) {
        amplitude = [value floatValue];
    }
    else if ([address isEqualToString:@"/freqSlider"]) {
        frequency = [value floatValue];
    }
    else if ([address isEqualToString:@"/change"]) {
        if ([value intValue] == 0) {
            //AMfrequency = 0.0;
        }
        else if ([value intValue] == 1) {
            //AMfrequency = 1.0;
        }
        else if ([value intValue] == 2) {
            //AMfrequency = 4.0;
        }
    }
    else if ([address isEqualToString:@"/amSlider"]) {
        AMfrequency = [value floatValue];
    }
    else if ([address isEqualToString:@"/onOffOscillator"])
    {
    //    [self togglePlay:[value intValue]]; //test
    }
    
    else if ([address isEqualToString:@"/buildButton"]) {
        NSString *stringToParse = [value stringValue];
        NSArray *ttsInterfaceVariables = [stringToParse componentsSeparatedByString: @"_"];
        NSString *buttonTitle = [ttsInterfaceVariables objectAtIndex:0];
        NSNumber *leftMargin = [ttsInterfaceVariables objectAtIndex:1];
        NSInteger valueLeftMargin = [leftMargin integerValue];
        NSNumber *topMargin = [ttsInterfaceVariables objectAtIndex:2];
        NSInteger valueTopMargin = [topMargin integerValue];
        NSNumber *firstWidth = [ttsInterfaceVariables objectAtIndex:3];
        NSInteger valueOfWidth = [firstWidth integerValue];
        NSNumber *firstHeight = [ttsInterfaceVariables objectAtIndex:4];
        NSInteger valueOfHeight = [firstHeight integerValue];
        NSString *buttFunc = [ttsInterfaceVariables objectAtIndex:5];
        
        dispatch_async(dispatch_get_main_queue(),^ {
            [self makeDynamicButton:buttonTitle buttonLeftMargin:valueLeftMargin buttonTopMargin:valueTopMargin buttonWidth:valueOfWidth buttonHeight:valueOfHeight buttonFunction:buttFunc];
        });
        txt = [NSString stringWithFormat:@"%@ %i %i %i %i %@", buttonTitle, valueLeftMargin, valueTopMargin, valueOfWidth, valueOfHeight, buttFunc];
    }
    else if ([address isEqualToString:@"/deleteButtons"]) {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self.view removeFromSuperview];
        });
        
        txt = @"add delete view function here";
        
    }
    
    else if ([address isEqualToString:@"/stringy"]) {
        dispatch_async( dispatch_get_main_queue(),^ {
            NSLog(@"string from /stringy %@",[value stringValue]);
        });
        txt = @"stringy";
    }
    
    
    //Text To Speech
    /*
     [fliteEngine speakText:@"It works."];	// Make it talk
     [fliteEngine setPitch:100.0 variance:50.0 speed:1.0];	// Change the voice properties
     [fliteEngine setVoice:@"cmu_us_awb"];	// Switch to a different voice
     [fliteEngine stopTalking];				// stop talking
     */
    
    else if ([address isEqualToString:@"/tts"]) {
		message = [NSString stringWithFormat:@"%@", [value stringValue]];
        txt = [NSString stringWithFormat:@"%@", [value stringValue]];
        [fliteEngine speakText:message];
	}
    
    else if ([address isEqualToString:@"/ttsvariables"]) {
        NSArray *ttsThreeVariables = [[value stringValue] componentsSeparatedByString:@"/"];
        txt = [value stringValue];
        [fliteEngine setPitch:[[ttsThreeVariables objectAtIndex: 0] floatValue] variance:[[ttsThreeVariables objectAtIndex: 1] floatValue] speed:[[ttsThreeVariables objectAtIndex: 2] floatValue]];
	}
    // [receivingDataLabel performSelectorOnMainThread:@selector(setText:) withObject:txt waitUntilDone:NO];
    //replace with dispatch_async . . .po
    dispatch_async(dispatch_get_main_queue(),^ {
        receivingDataLabel.text = txt;
    });
}

- (void)sendOSCMessage:(float)floatMessage label:(NSString*)label {
    outPort = [manager createNewOutputToAddress:sendingToIP atPort:sendingToPort];
	OSCMessage *msg = [OSCMessage createWithAddress:label];
	//[msg addString:[NSString stringWithFormat:@"%@", [self getMyWifiIP]]];
    [msg addFloat:floatMessage];
    [outPort sendThisPacket:[OSCPacket createWithContent:msg]];
    receivingDataLabel.text = [NSString stringWithFormat:@"%@", msg];
}


- (void)sendOSCStringMessage:(NSString  *)stringMessage label:(NSString*)label {
    outPort = [manager createNewOutputToAddress:sendingToIP atPort:sendingToPort];
    OSCMessage *msg = [OSCMessage createWithAddress:label];
	//[msg addString:[NSString stringWithFormat:@"%@", [self getMyWifiIP]]];
    [msg addString:stringMessage];
	receivingDataLabel.text = [NSString stringWithFormat:@"%@", [OSCPacket createWithContent:msg]];
    [outPort sendThisPacket:[OSCPacket createWithContent:msg]];
    //sendingInfoLabel.text = [NSString stringWithFormat:@"%@", msg];
}

- (void)sendOSCIPMessage:(NSString*)stringMessage label:(NSString*)label {
	 outPort = [manager createNewOutputToAddress:sendingToIP atPort:sendingToPort];
    OSCMessage *msg = [OSCMessage createWithAddress:label];
	//[msg addString:[NSString stringWithFormat:@"%@", [self getMyWifiIP]]];
    [msg addString:stringMessage];
	[outPort sendThisPacket:[OSCPacket createWithContent:msg]];
    receivingDataLabel.text = [NSString stringWithFormat:@"%@", msg];
}

- (void)makeDynamicButton:(NSString *)buttonTitle buttonLeftMargin:(int)leftMargin buttonTopMargin:(int)topMargin buttonWidth:(int)width buttonHeight:(int)height buttonFunction:(NSString *)buttFunc {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if ([buttFunc isEqualToString:@"pitchUp"]) {
        [btn addTarget:self action:@selector(pitchUp:) forControlEvents:UIControlEventTouchDown];
    }
    else if ([buttFunc isEqualToString:@"pitchDown"]) {
        [btn addTarget:self action:@selector(pitchDown:)forControlEvents:UIControlEventTouchDown];
    }
    else if ([buttFunc isEqualToString:@"modUp"]) {
        [btn addTarget:self action:@selector(modUp:)forControlEvents:UIControlEventTouchDown];
    }
    else if ([buttFunc isEqualToString:@"modDown"]) {
        [btn addTarget:self action:@selector(modDown:)forControlEvents:UIControlEventTouchDown];
    }
    else if ([buttFunc isEqualToString:@"speedUp"]) {
        [btn addTarget:self action:@selector(speedUp:)forControlEvents:UIControlEventTouchDown];
    }
    else if ([buttFunc isEqualToString:@"speedDown"]) {
        [btn addTarget:self action:@selector(speedDown:)forControlEvents:UIControlEventTouchDown];
    }
    
    [btn setTitle:buttonTitle forState:UIControlStateNormal];
    btn.frame = CGRectMake(leftMargin, topMargin, width, height);
    [self.view addSubview:btn];
    
}


-(NSString *) getMyWifiIP {
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) // this second test keeps from picking up the loopback address
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
				if ([name isEqualToString:@"en0"]) { // found the WiFi adapter
					return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
				}
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return NULL;
}

//oscillator methods
/*
 - (IBAction)sliderChanged:(UISlider *)slider
 {
 frequency = slider.value;
 frequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", frequency];
 }
 */
#ifdef FUCKBUBBLE
- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %hd", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %hd", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}


//- (IBAction)togglePlay:(UIButton *)selectedButton
- (void)togglePlay:(boolean_t)togOscillator
{
    
    if ((toneUnit) && (togOscillator == 0))
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		
		//[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	else if (togOscillator == 1)
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %hd", err);
		
		//[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	}
}

- (void)stop
{
	if (toneUnit)
	{
		[self togglePlay:0];
	}
}

#endif
//end oscillator methods

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (IBAction)refresh:(id) sender {
    [self loadView];
}

- (void)refresh2:(id) sender {
    [self loadView];
}

- (void)viewDidUnload {
    self.frequencyLabel = nil;
    self.playButton = nil;
    self.frequencySlider = nil;

#ifdef FUCKBUBBLE
    AudioSessionSetActive(false);
#endif
}
// Release any retained subviews of the main view.
// e.g. self.myOutlet = nil;

- (void)dealloc {
	[manager setDelegate:nil];
	
    //[manager release];
    //[xLabel release];
    //[yLabel release];
    //[zLabel release];
    
    // accelerometer.delegate = nil;
    // [accelerometer release];
    
    // 
}

@end
