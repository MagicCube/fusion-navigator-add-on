
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

void switchToHomeViewOrientation() {
    auto viewport = app->activeViewport();
    auto camera = viewport->camera();
    
    auto eye = camera->eye();
    auto target = camera->target();
    auto upVector = camera->upVector();

    eye->x(25.611467);
    eye->y(25.611467);
    eye->z(25.611467);

    target->x(0);
    target->y(0);
    target->z(0);

    upVector->x(0);
    upVector->y(1);
    upVector->z(0);

    camera->eye(eye);
    camera->target(target);
    camera->upVector(upVector);
    camera->viewExtents(247.286294);    
    camera->isSmoothTransition(true);
    
    // Refresh viewport
    viewport->camera(camera);
    viewport->refresh();
}

@implementation NSApplication (Tracking)
- (void)hookedSendEvent:(NSEvent *)event {
    if (app->activeViewport()) {
        // If has active viewport
        if (event.type == NSEventTypeKeyDown) {
            // Only capture key down events
            if (
                ((event.modifierFlags & NSEventModifierFlagControl) && (event.modifierFlags & NSEventModifierFlagOption)) ||
                ((event.modifierFlags & NSEventModifierFlagCommand) && (event.modifierFlags & NSEventModifierFlagShift))
            ) {
                // Control + Option(Alt)
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
                        switchToHomeViewOrientation();
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
