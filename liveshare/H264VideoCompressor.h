//
//  H264VideoCompressor.h
//  liveshare
//
//  Created by Cleiton A Souza on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface H264VideoCompressor : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>{
@private
    NSURL *videoFileURL;
    AVAssetWriterInputPixelBufferAdaptor *imageInputAdaptor;
    AVAssetWriter *videoWriter;
    uint64_t currentEndLocation;
    NSNumber *compressionBitRateMbit;
}

@property (nonatomic, retain) NSURL *videoFileURL;
@property (nonatomic, retain)  AVCaptureSession *capSession;
@property (nonatomic, retain)  AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, retain)  AVCaptureAudioDataOutput *audioOutput;

@property (nonatomic, strong)  AVAssetWriter *videoWriter;

@property (nonatomic, retain)  AVAssetWriterInput *videoWriterInput;
@property (nonatomic, retain)  AVAssetWriterInput *audioWriterInput;
@property (nonatomic, assign)  bool isRecording;
@property (nonatomic, assign) CMTime lastSampleTime;


-(void)initializerVideoAudioDataOutPut;
-(void)prepareForVideosWithDestinationFolderURL:(NSString *)destination videoName:(NSString *)name;
-(bool)setupWriter;


-(void) startVideoRecording;
-(void) stopVideoRecording;

@end
