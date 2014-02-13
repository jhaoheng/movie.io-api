//
//  baseViewController.m
//  movie.io
//
//  Created by jhaoheng on 2014/2/14.
//  Copyright (c) 2014年 max. All rights reserved.
//

#import "baseViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface baseViewController ()

@end

@implementation baseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	// Do any additional setup after loading the view.
    
    NSMutableDictionary *dic = [self json_work:@"http://api.movies.io/movies/search?q=hobbit"];
    
    NSMutableArray *movieJson = [[NSMutableArray alloc] init];
    movieJson = [dic objectForKey:@"movies"];
    
    
    movieInfo = [[NSMutableArray alloc]init];
    for (int i=0; i<[movieJson count]; i++) {
        
        bookfaceRecord *temp = [[bookfaceRecord alloc]init];
        temp.title = [[movieJson objectAtIndex:i] objectForKey:@"title"];
        temp.rating = [[movieJson objectAtIndex:i] objectForKey:@"rating"];
        temp.year = [[movieJson objectAtIndex:i] objectForKey:@"year"];
        temp.posterUrl = [[[[movieJson objectAtIndex:i] objectForKey:@"poster"] objectForKey:@"urls"] objectForKey:@"w154"];
        [movieInfo addObject:temp];
    }
    
//    NSLog(@"%@",array);
//    NSLog(@"%d", [movieIoJson count]);
//    NSLog(@"%@",[movieIoJson objectAtIndex:0]);
    
    UILabel *resultText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20+10, 280, 18)];
    resultText.text = [NSString stringWithFormat:@"%d results for 'hobbit'",movieInfo.count];
    resultText.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:resultText];
    
    CGRect mainTableFrame = CGRectMake(0, CGRectGetMaxY(resultText.frame)+5, 320, self.view.frame.size.height-CGRectGetMaxY(resultText.frame)-5);
    mainTable = [[UITableView alloc] initWithFrame:mainTableFrame style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    [self.view addSubview:mainTable];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    bookfaceRecord *movieRecord = [movieInfo objectAtIndex:indexPath.row];
    float h = [self setLabelHeight:movieRecord.title minHeight:12];
    if (h+24+10>44) {
        return h+24+10;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [movieInfo count];
	
    if (count == 0)
	{
        return 10;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel *cellTitle,*cellYear,*cellRating;
    UIImageView *cellImage;
    
    bookfaceRecord *movieRecord = [movieInfo objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        float h = [self setLabelHeight:movieRecord.title minHeight:12];
        cellTitle = [[UILabel alloc]initWithFrame:CGRectMake(75, 2, 240, h)];
        cellTitle.backgroundColor = [UIColor clearColor];
        cellTitle.tag = 100;
        cellTitle.font = [UIFont systemFontOfSize:12];
        cellTitle.lineBreakMode = NSLineBreakByWordWrapping;
        cellTitle.numberOfLines = 0;
        [cell addSubview:cellTitle];
        
        cellYear = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(cellTitle.frame)+2, 240, 12)];
        cellYear.backgroundColor = [UIColor clearColor];
        cellYear.tag = 200;
        cellYear.font = [UIFont systemFontOfSize:12];
        [cell addSubview:cellYear];
        
        
        cellRating = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(cellYear.frame)+2, 240, 12)];
        cellRating.backgroundColor = [UIColor clearColor];
        cellRating.font = [UIFont systemFontOfSize:12];
        cellRating.tag = 300;
        [cell addSubview:cellRating];
        
        cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 4+(CGRectGetMaxY(cellRating.frame)-48)/2, 44, 44)];
        cellImage.layer.cornerRadius = 3.5;
        cellImage.layer.masksToBounds = YES;
        cellImage.layer.borderWidth = 1;
        cellImage.layer.borderColor = [[UIColor grayColor] CGColor];
        cellImage.tag = 50;
        [cell addSubview:cellImage];
    }
    
    
    cellTitle.text = movieRecord.title;
    cellYear.text = [NSString stringWithFormat:@"%@",movieRecord.year];
    cellRating.text = [NSString stringWithFormat:@"%@",movieRecord.rating];
    
    if (!movieRecord.poster)
    {
        if (mainTable.dragging == NO && mainTable.decelerating == NO)
        {
            [self startIconDownload:movieRecord forIndexPath:indexPath];
        }
        
        
        cellImage.image = [UIImage imageNamed:@"noImages"];
        
        movieRecord.indicator = [[UIActivityIndicatorView alloc]init];
        movieRecord.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [movieRecord.indicator startAnimating];
        movieRecord.indicator.center = CGPointMake(20, 20);
        [cellImage addSubview:movieRecord.indicator];
    }
    else
    {
        cellImage.image = movieRecord.poster;
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    if ([movieInfo count] > 0)
    {
        NSArray *visiblePaths = [mainTable indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            bookfaceRecord *faceRecord = [movieInfo objectAtIndex:indexPath.row];
            
            if (!faceRecord.poster)
            {
                [self startIconDownload:faceRecord forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - download
- (void)startIconDownload:(bookfaceRecord *)movieRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.movieRecord = movieRecord;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [mainTable cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            UIImageView *cellImage = (UIImageView *)[cell viewWithTag:50];
            cellImage.image = movieRecord.poster;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
            [movieRecord.indicator stopAnimating];
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}


#pragma mark - movie.io api
- (NSMutableDictionary *)json_work:(NSString *)urlStr
{
    /*
     須先判斷該網址是否有效
     */
    
    //NSLog(@"%@",str);
    //NSLog(@"%@",[self hostCheckUp:str]);
    NSURL *url = [[NSURL alloc]initWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@",url);
//    NSLog(@"%@:%@",[url host],[url path]);
//    NSLog(@"%@",[url query]);
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    
    //檢驗hostname是否有效
    if([[self hostCheckUp:[url host]] isEqualToString:@"ok"])
    {
        //        NSLog(@"這邊:%@",str);
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        //        NSLog(@"here:%@",data);
        NSError *jsonError = [[NSError alloc]init];
        
        dict = [NSJSONSerialization JSONObjectWithData:data //1
                                               options:kNilOptions
                                                 error:&jsonError
                ];
        if ([NSJSONSerialization isValidJSONObject:dict]) {
            return dict;//注意返回的字典直接nslog的話，顯示為unicode，若將字典內容的value，直接輸出成string即可
        }
        else {
            return nil;
        }
    }
    else {
        [dict setObject:@"server error 404" forKey:@"errorMsg"];
        return dict;
    }
}

//解析該網址hostname或者ip是否有效
-(NSString *) hostCheckUp:(NSString *)urlHost
{
    CFStreamError errorTest;
//    NSLog(@"%@",urlHost);
    CFHostRef myHost = CFHostCreateWithName(kCFAllocatorDefault,(__bridge CFStringRef)urlHost);
//    NSLog(@"%@",myHost);
    if (myHost)
    {
        if (CFHostStartInfoResolution(myHost, kCFHostAddresses, &errorTest))
        {
            //lbloutput.text = [tfinput.text stringByAppendingString:@" 解析成功！"];
            return @"ok";
        }
        else
        {
            //lbloutput.text = [tfinput.text stringByAppendingFormat:@" 無法解析 (錯誤: %i).",errorTest.error];
            return @"false";
        }
    }
    CFRelease(myHost);
    return @"nothing";
}


#pragma mark - 判斷label frame的高度
- (float) setLabelHeight : (NSString *)str minHeight : (float)minHeight
{
    CGSize constraint = CGSizeMake(240 , 20000.0f);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect textRect = [str boundingRectWithSize:constraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:minHeight],NSParagraphStyleAttributeName: paragraphStyle.copy}
                                         context:nil];
    
    CGSize size = textRect.size;
    
    CGFloat height = MAX(minHeight, size.height);
    //NSLog(@"%f:%f",size.height,height);
//    NSLog(@"%f",height);
    return height;
}




@end
