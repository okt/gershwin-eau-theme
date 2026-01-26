/* NSButton+Eau.m - Eau theme button keyboard handling
   Copyright (C) 2026 Free Software Foundation, Inc.

   This file is part of GNUstep.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#import "NSButton+Eau.h"
#import "Eau.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

@implementation NSButton (EauKeyboardHandling)

+ (void) load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [NSButton class];
    SEL origSelector = @selector(keyDown:);
    SEL swizSelector = @selector(eau_keyDown:);
    
    Method origMethod = class_getInstanceMethod(cls, origSelector);
    Method swizMethod = class_getInstanceMethod(cls, swizSelector);
    
    // Attempt to add the method first in case NSButton doesn't implement it directly
    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizMethod),
                                        method_getTypeEncoding(swizMethod));
    
    if (didAddMethod)
      {
        class_replaceMethod(cls,
                            swizSelector,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
      }
    else
      {
        method_exchangeImplementations(origMethod, swizMethod);
      }
  });
}

/**
 * Swizzled keyDown to ensure spacebar activates buttons with focus ring.
 */
- (void) eau_keyDown: (NSEvent*)theEvent
{
  NSString *characters = [theEvent characters];
  
  if ([self isEnabled] && [characters length] > 0)
    {
      unichar keyChar = [characters characterAtIndex: 0];
      
      // Handle spacebar - critical for focus ring interaction
      if (keyChar == ' ' || keyChar == 0x20)
        {
          [self performClick: self];
          return;
        }
      
      // Handle Enter/Return
      if (keyChar == '\r' || keyChar == '\n' || keyChar == 0x03)
        {
          [self performClick: self];
          return;
        }
    }
  
  // Call the original implementation (which now points to eau_keyDown)
  [self eau_keyDown: theEvent];
}

@end
