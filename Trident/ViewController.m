//
//  ViewController.m
//  Trident
//
//  Created by Benjamin Randazzo on 06/11/2016.
//  Copyright © 2016 Benjamin Randazzo. All rights reserved.
//

#import "ViewController.h"

#include <sys/utsname.h>
#include "offsetfinder.h"

void initialize(void);
uint32_t leak_kernel_base(void);
void exploit(uint32_t);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *environmentLabel;
@end

@implementation ViewController
void postExploit();
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize environment target.
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    struct utsname name;
    NSString *environment;
    
    uname(&name);
    init_target_environment(name.machine, [systemVersion cStringUsingEncoding:NSUTF8StringEncoding]);
    
    // Update interface.
    environment = [NSString stringWithFormat:@"%s - iOS %@", name.machine, systemVersion];
    if (target_environment == NotSupported) {
        self.button.enabled = NO;
        environment = [environment stringByAppendingString:@" (not supported)"];
    }
    self.environmentLabel.text = environment;
    
    int ret = setreuid(0, 0);
    printf("setreuid(0, 0) returned %d\n",ret);
    
    
    char* nm = strdup("/dev/disk0s1s1");
    int mntr = mount("hfs", "/", 0x10000, &nm);
    printf("mount=%d\n",mntr);
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    initialize();
    uint32_t kernel_base = leak_kernel_base();
    printf("kernel base: %p\n", (void *)kernel_base);
    exploit(kernel_base);
    
    // Update button.
    self.button.enabled = NO;
    [self.button setTitle:@"w00t root" forState:UIControlStateNormal];
}

@end
