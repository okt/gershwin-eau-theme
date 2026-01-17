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

@implementation NSButton(EauKeyboardHandling)

/**
 * Override keyDown to ensure spacebar activates buttons with focus ring.
 * This is critical for keyboard accessibility - when a button has keyboard focus
 * (shown by the focus ring), pressing spacebar should activate it.
 */
- (void) keyDown: (NSEvent*)theEvent
{
  NSString *characters = [theEvent characters];
  
  EAULOG(@"NSButton+Eau: keyDown received for button '%@', enabled: %d, characters: '%@'", 
         [self title], [self isEnabled], characters);
  
  if ([self isEnabled] && [characters length] > 0)
    {
      unichar keyChar = [characters characterAtIndex: 0];
      
      // Handle spacebar - this is the key requirement for focus ring interaction
      if (keyChar == ' ' || keyChar == 0x20)
        {
          EAULOG(@"NSButton+Eau: Spacebar pressed on button '%@', performing click", [self title]);
          [self performClick: self];
          return;
        }
      
      // Handle Enter/Return key as well for default buttons
      if (keyChar == '\r' || keyChar == '\n' || keyChar == 0x03)
        {
          EAULOG(@"NSButton+Eau: Enter/Return pressed on button '%@', performing click", [self title]);
          [self performClick: self];
          return;
        }
    }
  
  // Pass through to super for any other keys
  [super keyDown: theEvent];
}

@end
