
#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <CAM/CAMAll.h>

#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

#import <objc/runtime.h>

using namespace std;
using namespace adsk::core;
using namespace adsk::fusion;
using namespace adsk::cam;

Ptr<Application> app;
Ptr<UserInterface> ui;

void switchViewOrientation(ViewOrientations orientation) {
    auto viewport = app->activeViewport();
    auto camera = viewport->camera();
    camera->isSmoothTransition(true);
    camera->viewOrientation(orientation);
    // Refresh viewport
    viewport->camera(camera);
    viewport->refresh();
}

@implementation NSApplication (Tracking)
- (void)hookedSendEvent:(NSEvent *)event {
    if (app->activeViewport()) {
        if (event.type == NSEventTypeKeyDown) {
            if ((event.modifierFlags & NSEventModifierFlagControl) && (event.modifierFlags & NSEventModifierFlagOption)) {
                switch (event.keyCode) {
                    case 123:
                        // Left
                        switchViewOrientation(LeftViewOrientation);
                        return;
                    case 124:
                        // Right
                        switchViewOrientation(RightViewOrientation);
                        return;
                    case 125:
                        // Down
                        switchViewOrientation(BottomViewOrientation);
                        return;
                    case 126:
                        // Up
                        switchViewOrientation(TopViewOrientation);
                        return;
                    case 3:
                        // F
                        switchViewOrientation(FrontViewOrientation);
                        return;
                    case 11:
                        // B
                        switchViewOrientation(BackViewOrientation);
                        return;
                    case 4:
                    case 36:
                        // H or Enter
                        switchViewOrientation(IsoTopRightViewOrientation);
                        return;
                    default:
                        break;
                }
            }
        }
    }
    // Do nothing
    [self hookedSendEvent:event];
}

- (void)hook {
    Method original = class_getInstanceMethod([self class], @selector(sendEvent:));
    Method swizzled = class_getInstanceMethod([self class], @selector(hookedSendEvent:));
    
    method_exchangeImplementations(original, swizzled);
}
@end

extern "C" XI_EXPORT bool run(const char* context)
{
	app = Application::get();
	if (!app)
		return false;

	ui = app->userInterface();
	if (!ui)
		return false;
    
    [NSApplication.sharedApplication hook];

	return true;
}

extern "C" XI_EXPORT bool stop(const char* context)
{
    [NSApplication.sharedApplication hook];
	return true;
}
