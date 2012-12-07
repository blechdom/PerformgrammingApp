//
//  prfgrmViewController.h
//  accelerometer
//
//  Created by Kristin Erickson on 10/1/12.
//  Copyright (c) 2012 MTBrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface prfgrmViewController : UIViewController <UIAccelerometerDelegate>
{
    IBOutlet UILabel *xLabel;
    IBOutlet UILabel *yLabel;
    IBOutlet UILabel *zLabel;
    
    UIAccelerometer *accelerometer;
}
@end
