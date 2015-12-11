//
//  CALayer+Animations.m
//  UniversalHotels
//
//  Created by Daren David Taylor on 19/02/2014.
//
//

#import "CALayer+Animations.h"

@implementation CALayer (Animations)

- (void)animateWithType:(NSString *)type duration:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition animation];
    animation.type = type;
    animation.duration = duration;
    [self addAnimation:animation forKey:nil];
}

@end
