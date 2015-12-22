//
//  ViewController.h
//  jkajsfkjasf
//
//  Created by 周鹏翔 on 15/11/11.
//  Copyright © 2015年 周鹏翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    NSDate *                        systemTime;
    NSDate *                        networkTime;
    
      UILabel *              sysClockLabel;
      UILabel *              netClockLabel;
      UILabel *              differenceLabel;
    
    UIButton  *  statrTime;
}

- (void) repeatingMethod:(NSTimer*)theTimer;
@end

