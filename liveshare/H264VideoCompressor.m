//
//  H264VideoCompressor.m
//  liveshare
//
//  Created by Cleiton A Souza on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "H264VideoCompressor.h"

static uint32_t const kExportTimeScale = 1000000000;
static NSString * const kCompressionBitRateMbitUserDefaultsKey = @"MegaBits";

@implementation H264VideoCompressor



@synthesize videoFileURL;
@synthesize capSession;
@synthesize videoOutput;
@synthesize audioOutput;
@synthesize videoWriter;
@synthesize videoWriterInput;
@synthesize audioWriterInput;
@synthesize isRecording;
@synthesize lastSampleTime;

-(NSString *)name {
    return NSLocalizedStringFromTableInBundle(@"H264CompressorName", @"Localizable", [NSBundle bundleForClass:[self class]], @"H.264");
}

-(void)prepareForVideosWithDestinationFolderURL:(NSString *)destination videoName:(NSString *)name {
    
    if (![[name pathExtension] isEqualToString:@"mp4"]){
        name = [name stringByAppendingPathExtension:@"mp4"];
    }    
    self.videoFileURL = [self fileURLWithUniqueNameForFile:name inParentDirectory:destination];
}

-(NSURL *)fileURLWithUniqueNameForFile:(NSString *)fileName inParentDirectory:(NSString *)parent {
    
	// This method passes back a unique file name for the passed file and path(s). 
	// So, for example, if the caller wants to put a file called "Hello.txt" in ~/Desktop
	// and that file already exists, it'll give back ~/Desktop/Hello 2.txt".
	// The method respects extensions and will keep incrementing the number until it finds a 
	// name that's unique in the given directory. 
    
	NSUInteger numericSuffix = 2;
	
    NSURL *potentialURL  = [NSURL fileURLWithPath:[parent stringByAppendingFormat:fileName, nil]];
    
    BOOL fileURLAvailable = ![potentialURL checkResourceIsReachableAndReturnError:nil];
    
    while ((!fileURLAvailable)) {
        
        NSString *newName = [NSString stringWithFormat:@"%@ %d.%@", [fileName stringByDeletingPathExtension], numericSuffix, [fileName pathExtension]];
        potentialURL =  [NSURL fileURLWithPath:[parent stringByAppendingFormat:newName, nil]];
        fileURLAvailable = ![potentialURL checkResourceIsReachableAndReturnError:nil];
        numericSuffix++;
    }    
	return potentialURL;
}

-(void)initializerVideoAudioDataOutPut{
    
    NSError *error = nil;
    
    // Setup the video input make input device
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    
    // Setup the video output
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = NO;
    self.videoOutput.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];     
    
    // Setup the audio input
    AVCaptureDevice *audioDevice     = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error ];     
    // Setup the audio output
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    // initialize capture session
    self.capSession = [[AVCaptureSession alloc] init];
    self.capSession.sessionPreset = AVCaptureSessionPreset640x480;
    [self.capSession addInput:videoInput];
    [self.capSession addInput:audioInput];
    [self.capSession addOutput:self.videoOutput];
    [self.capSession addOutput:self.audioOutput];
    
    // Setup the queue
    dispatch_queue_t queue = dispatch_queue_create("CaptureQueue", NULL);
    [self.videoOutput setSampleBufferDelegate:self queue:queue];
    [self.audioOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
}

-(bool)setupWriter{
    
    NSError *error = nil;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:self.videoFileURL fileType:AVFileTypeMPEG4
                                                error:&error];
    NSParameterAssert(self.videoWriter);
    
    // Add video input
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:900.0*1024.0],
                                           AVVideoAverageBitRateKey,
                                           nil ];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   AVVideoScalingModeResizeAspectFill, AVVideoScalingModeKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   nil];
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                           outputSettings:videoSettings];
    
    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
    // Add the audio input
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    
    NSDictionary* audioOutputSettings = nil;          
    // Both type of audio inputs causes output video file to be corrupted.
    if( NO ) {
        // should work from iphone 3GS on and from ipod 3rd generation
        audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                               [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                               [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                               [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                               [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
                               [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                               nil];
    } else {
        // should work on any device requires more space
        audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                               [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                               [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                               [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                               [ NSData dataWithBytes: &acl length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                               [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
                               nil];
    } 
    
    self.audioWriterInput = [AVAssetWriterInput 
                         assetWriterInputWithMediaType: AVMediaTypeAudio 
                         outputSettings: audioOutputSettings];
    
    self.audioWriterInput.expectsMediaDataInRealTime = YES;
    
    // add input
    [self.videoWriter addInput:self.videoWriterInput];
    [self.videoWriter addInput:self.audioWriterInput];
    
    return YES;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    
    if( self.isRecording == YES )
    {
        lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if( self.videoWriter.status != AVAssetWriterStatusWriting  )
        {
            [self.videoWriter startWriting];
            [self.videoWriter startSessionAtSourceTime:lastSampleTime];
        }
        
        if( captureOutput == self.videoOutput )
            [self addNewVideoSample:sampleBuffer];
        // If I add audio to the video, then the output file gets corrupted and it cannot be reproduced
        else
            [self addNewAudioSample:sampleBuffer];
        
    }
}


-(void)addNewVideoSample:(CMSampleBufferRef)sampleBuffer
{     
    if( self.isRecording )
    {
        if( self.videoWriter.status > AVAssetWriterStatusWriting )
        {
            NSLog(@"Warning: writer status is %d", self.videoWriter.status);
            if( self.videoWriter.status == AVAssetWriterStatusFailed )
                NSLog(@"Error: %@", self.videoWriter.error);
            return;
        }
        
        if( ![self.videoWriterInput appendSampleBuffer:sampleBuffer] )
            NSLog(@"Unable to write to video input");
    }
}

-(void)addNewAudioSample:(CMSampleBufferRef)sampleBuffer
{     
    if( self.isRecording )
    {
        if( self.videoWriter.status > AVAssetWriterStatusWriting )
        {
            NSLog(@"Warning: writer status is %d", self.videoWriter.status);
            if( self.videoWriter.status == AVAssetWriterStatusFailed )
                NSLog(@"Error: %@", self.videoWriter.error);
            return;
        }
             if( ![self.audioWriterInput appendSampleBuffer:sampleBuffer] )
               NSLog(@"Unable to write to audio input");
    }
}


-(void)startVideoRecording
{
    if( !self.isRecording )
    {
        NSLog(@"start video recording...");
        if( ![self setupWriter] ){
            NSLog(@"Setup Writer Failed") ;
            return;
        }
        [self.capSession startRunning];
        self.isRecording = YES;
    }
}

-(void)stopVideoRecording
{
    if( self.isRecording )
    {
        self.isRecording = NO;
        
        [self.capSession stopRunning];
        
        if(![self.videoWriter finishWriting]){
            [self.videoWriter finishWriting];
        }
        NSLog(@"video recording stopped");
    }
}


@end
