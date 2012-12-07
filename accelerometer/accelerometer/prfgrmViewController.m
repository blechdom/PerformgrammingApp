//
//  prfgrmViewController.m
//  accelerometer
//
//  Created by Kristin Erickson on 10/1/12.
//  Copyright (c) 2012 MTBrain. All rights reserved.
//

#import "prfgrmViewController.h"

@interface prfgrmViewController ()

@end

@implementation prfgrmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
        accelerometer = [UIAccelerometer sharedAccelerometer];
        accelerometer.updateInterval = 0.1;
        accelerometer.delegate = self;
        [super viewDidLoad];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration
{
    xLabel.text = [NSString stringWithFormat:@"%f", acceleration.x];
    yLabel.text = [NSString stringWithFormat:@"%f", acceleration.y];
    zLabel.text = [NSString stringWithFormat:@"%f", acceleration.z];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{

    [xLabel release];
    [yLabel release];
    [zLabel release];
    
    accelerometer.delegate = nil;
    [accelerometer release];
    [super dealloc];
}

@end
