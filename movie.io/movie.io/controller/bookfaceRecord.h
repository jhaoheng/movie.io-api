//
//  bookfaceRecord.h
//  TAAZE
//
//  Created by johann on 12/9/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface bookfaceRecord : NSObject
{
    UIImage *poster;
    NSString *posterUrl;
    NSString *title;
    NSString *year;
    NSString *rating;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain) UIImage *poster;
@property (nonatomic, retain) NSString *title,*year,*rating,*posterUrl;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;

@end
