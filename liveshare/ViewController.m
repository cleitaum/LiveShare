//
//  ViewController.m
//  liveshare
//
//  Created by Cleiton Amaral Souza on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
//http://stackoverflow.com/questions/4149963/this-code-to-write-videoaudio-through-avassetwriter-and-avassetwriterinputs-is

@interface ViewController ()

@end

@implementation ViewController
@synthesize captureButton;
@synthesize playButton;
@synthesize showFilesButton;
@synthesize deleteButton;
@synthesize _isRecording;
@synthesize h264Compressor;
@synthesize socket;

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.    
    for (UIButton *obj in [self.view subviews]) {
        
        if ([obj isKindOfClass:[UIButton class]]){
            
            obj.layer.cornerRadius = 4;
            obj.layer.shadowColor = [UIColor blackColor].CGColor;
            obj.layer.shadowOpacity = 0.4;
            obj.layer.shadowRadius = 3;
            obj.layer.shadowOffset = CGSizeMake(4, 4);
            obj.backgroundColor = [UIColor blueColor];
        }
    }  
    [self setupCapture];
    
     self.socket = [[SocketStream alloc] init];
}

-(void)setupCapture{
    
    self.h264Compressor = [[H264VideoCompressor alloc] init];
    [self.h264Compressor initializerVideoAudioDataOutPut];
    
    _isRecording = NO;
    /// make preview layer and add so that camera's view is displayed on screen
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.h264Compressor.capSession];
    previewLayer.frame = self.view.frame;
    [self.view.layer addSublayer:previewLayer];
}

    
- (IBAction)startCapture:(id)sender {
    
    [self.view bringSubviewToFront:showFilesButton];
    [self.view bringSubviewToFront:captureButton];
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:deleteButton];
    
    if (!_isRecording){
        
        [captureButton setTitle:@"Stop Rec" forState:UIControlStateNormal];
        captureButton.backgroundColor = [UIColor redColor];
        NSString *contentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        [self.h264Compressor prepareForVideosWithDestinationFolderURL:contentsPath videoName:@"/sample"];
        
        [self.h264Compressor startVideoRecording];
        _isRecording = YES;
    }
    else {
        captureButton.backgroundColor = [UIColor blueColor];
        [captureButton setTitle:@"Start Rec" forState:UIControlStateNormal];
        
        [self.h264Compressor stopVideoRecording];
        _isRecording = NO;
    }
}

- (IBAction)playCapturedVideo:(id)sender {
    
    PlayerViewControllerViewController * player = [[PlayerViewControllerViewController alloc] initWithNibName:@"PlayerViewControllerViewController" bundle:nil];
    
    player.tabBarItem.title = @"Player";
    [self.navigationController pushViewController:player animated:YES];
//    [self presentModalViewController:player animated:YES];
}

- (IBAction)showFiles:(id)sender {
    
    NSString *bundleRoot = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:bundleRoot];
    
    NSString *filename;
    
    while ((filename = [direnum nextObject] )) {
        
        if ([filename hasSuffix:@".mp4"]) {   //change the suffix to what you are looking for
            // Do work here
            NSError *attributesError = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.h264Compressor.videoFileURL.path error:&attributesError];
            
            NSLog(@"founded %@", filename);
             NSLog(@"fileAttributes %@", fileAttributes);
        }
    }
}

- (IBAction)deleteFiles:(id)sender {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
            NSLog(@"it failed %@", [NSString stringWithFormat:@"%@/%@", directory, file]);
        }
    }
}

- (void)viewDidUnload
{
    [self setCaptureButton:nil];
    [self setPlayButton:nil];
    [self setShowFilesButton:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
