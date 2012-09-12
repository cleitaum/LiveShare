//
//  PlayerViewControllerViewController.h
//  liveshare
//
//  Created by Cleiton A Souza on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerViewControllerViewController : UIViewController{
    MPMoviePlayerController *moviePlayer;
}

@property(strong, nonatomic) MPMoviePlayerController *moviePlayer;

@end
