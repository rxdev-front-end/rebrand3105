#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// A NOSSA INTERFACE
@interface MyCustomVC : UIViewController
@end

@implementation MyCustomVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 50)];
    title.text = @"MinhaApp 3105";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:32];
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(40, 200, self.view.bounds.size.width - 80, 60);
    [btn setTitle:@"Injetar Pet (Em breve)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor systemBlueColor];
    btn.layer.cornerRadius = 12;
    [self.view addSubview:btn];
}
@end

// O SEQUESTRO DA JANELA
%hook UIWindow
- (void)makeKeyAndVisible {
    %orig; // Deixa o app original carregar em background
    
    // Espera 1 segundo pro app terminar de iniciar, e troca a tela
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *mainWindow = self;
        
        // Cria a nossa janela por cima
        mainWindow.rootViewController = [[MyCustomVC alloc] init];
        
        // Da um fade suave pra ficar bonito
        [UIView transitionWithView:mainWindow duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [mainWindow makeKeyAndVisible];
        } completion:nil];
    });
}
%end
