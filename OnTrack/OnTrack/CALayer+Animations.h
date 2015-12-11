//
//  CALayer+Animations.h
//  UniversalHotels
//
//  Created by Daren David Taylor on 19/02/2014.
//
//

#import <QuartzCore/QuartzCore.h>

/*! 
 CALayer - Animations category
 */
@interface CALayer (Animations)

/*!
 Convenience method for performing an animation on the CALayer where
 UIView animation is not sufficient
 
 @param type example kCATransitionFade
 @param duration the duration of the animation
 */

- (void)animateWithType:(NSString *)type duration:(CFTimeInterval)duration;

@end
