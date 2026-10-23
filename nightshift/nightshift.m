#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <dlfcn.h>
#include <string.h>
typedef struct { int hour; int minute; } NSTime;
typedef struct { NSTime fromTime; NSTime toTime; } NSSchedule;
typedef struct {
  char active; char enabled; char sunSchedulePermitted; int mode;
  NSSchedule schedule; unsigned long long disableFlags; char available;
} NSStatus;
int main(int argc, char **argv) {
  @autoreleasepool {
    dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_NOW);
    Class c = NSClassFromString(@"CBBlueLightClient");
    if (!c) { printf("err"); return 1; }
    id cl = [[c alloc] init];
    NSStatus st; memset(&st, 0, sizeof(st));
    BOOL (*getS)(id, SEL, NSStatus *) = (void *)objc_msgSend;
    getS(cl, sel_registerName("getBlueLightStatus:"), &st);
    if (argc > 1 && strcmp(argv[1], "status") == 0) { printf(st.enabled ? "on" : "off"); return 0; }
    BOOL on = !st.enabled;
    BOOL (*setS)(id, SEL, float, BOOL) = (void *)objc_msgSend;
    BOOL (*setE)(id, SEL, BOOL) = (void *)objc_msgSend;
    if (on) setS(cl, sel_registerName("setStrength:commit:"), 0.6f, YES);
    setE(cl, sel_registerName("setEnabled:"), on);
  }
  return 0;
}
