//
//  PlayerViewControllerViewController.m
//  liveshare
//
//  Created by Cleiton A Souza on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerViewControllerViewController.h"

@interface PlayerViewControllerViewController ()

@end

@implementation PlayerViewControllerViewController
@synthesize moviePlayer;

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
    // Do any additional setup after loading the view from its nib.
    
[self.navigationController.navigationBar setHidden:NO];
    
    [self.view setTransform:CGAffineTransformMakeRotation( ( 90 * M_PI ) / 180 )];
    
    NSMutableArray *filesArray = [[NSMutableArray alloc] init];
    
    NSString *bundleRoot = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:bundleRoot];
    
    NSString *filename;
    
    while ((filename = [direnum nextObject] )) {
        
        if ([filename hasSuffix:@".mp4"]) {   //change the suffix to what you are looking for
            // Do work here
            [filesArray addObject:filename];
        }
    }
   
    filename = [filesArray objectAtIndex:filesArray.count -1];
    
    bundleRoot = [bundleRoot stringByAppendingFormat:[NSString stringWithFormat:@"/%@",filename]];
    
    NSURL *url = [NSURL fileURLWithPath:bundleRoot];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [moviePlayer setFullscreen:YES animated:NO];
    moviePlayer.shouldAutoplay = YES;
    moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];

    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [self.view addSubview:moviePlayer.view];    
    [moviePlayer play];
}


- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player  respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
