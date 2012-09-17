//
//  ViewController.h
//  liveshare
//
//  Created by Cleiton Amaral Souza on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "H264VideoCompressor.h"
#import "PlayerViewControllerViewController.h"
#import "SocketStream.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *showFilesButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@property (nonatomic, assign)  bool _isRecording;

@property (nonatomic, strong)  H264VideoCompressor *h264Compressor;
@property (nonatomic, strong)  SocketStream *socket;

- (IBAction)startCapture:(id)sender;
- (IBAction)playCapturedVideo:(id)sender;
- (IBAction)showFiles:(id)sender;
- (IBAction)deleteFiles:(id)sender;


@end
