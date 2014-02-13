//
//  baseViewController.h
//  movie.io
//
//  Created by jhaoheng on 2014/2/14.
//  Copyright (c) 2014年 max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bookfaceRecord.h"
#import "IconDownloader.h"

@interface baseViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    
    UITableView *mainTable;
    
    NSMutableArray *movieInfo;
}

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end
