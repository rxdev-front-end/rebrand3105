#import <UIKit/UIKit.h>

// Variável global para guardar a tela original do 3105
static UIViewController *originalVC;

// --- CUSTOM CELL (O Card do Patch) ---
@interface PatchCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UISwitch *toggle;
@end

@implementation PatchCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Fundo do card (Vermelho escuro quase preto)
        _cardView = [[UIView alloc] initWithFrame:CGRectZero];
        _cardView.backgroundColor = [UIColor colorWithRed:0.12 green:0.05 blue:0.05 alpha:1.0];
        _cardView.layer.cornerRadius = 12;
        _cardView.layer.borderWidth = 1.0;
        _cardView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.1 blue:0.1 alpha:1.0].CGColor;
        [self.contentView addSubview:_cardView];
        
        // Ícone do lado esquerdo
        UIView *iconBg = [[UIView alloc] initWithFrame:CGRectZero];
        iconBg.backgroundColor = [UIColor colorWithRed:0.2 green:0.05 blue:0.05 alpha:1.0];
        iconBg.layer.cornerRadius = 8;
        [_cardView addSubview:iconBg];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"scope"]];
        icon.tintColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:icon];
        
        // Título do patch
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_cardView addSubview:_titleLabel];
        
        // Tag "NORMAL"
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.text = @" NORMAL ";
        _tagLabel.textColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];
        _tagLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.05 blue:0.05 alpha:1.0];
        _tagLabel.font = [UIFont boldSystemFontOfSize:10];
        _tagLabel.layer.cornerRadius = 4;
        _tagLabel.layer.masksToBounds = YES;
        [_cardView addSubview:_tagLabel];
        
        // Subtítulo
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        [_cardView addSubview:_subtitleLabel];
        
        // Botão de ligar/desligar (Toggle)
        _toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
        _toggle.onTintColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
        [_cardView addSubview:_toggle];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _cardView.frame = CGRectMake(15, 5, self.contentView.bounds.size.width - 30, 75);
    
    UIView *iconBg = _cardView.subviews[0];
    iconBg.frame = CGRectMake(12, 15, 45, 45);
    iconBg.subviews[0].frame = CGRectMake(10, 10, 25, 25);
    
    _titleLabel.frame = CGRectMake(70, 15, 200, 20);
    _tagLabel.frame = CGRectMake(70 + [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}].width + 5, 16, 60, 16);
    _subtitleLabel.frame = CGRectMake(70, 40, 200, 20);
    
    _toggle.frame = CGRectMake(_cardView.bounds.size.width - 60, 22, 51, 31);
}
@end

// --- NOSSA INTERFACE PRINCIPAL ---
@interface MyCustomVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *patches;
@end

@implementation MyCustomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.02 blue:0.02 alpha:1.0];
    
    // Dados fake só pra preencher a tela igual a sua print
    _patches = @[
        @{@"title": @"HS GIRAFA", @"status": @"Estado não verificado"},
        @{@"title": @"HS CEARENSE", @"status": @"Estado não verificado"},
        @{@"title": @"HS PESCOÇO + ANTENA", @"status": @"Estado não verificado"},
        @{@"title": @"HS PEITO + ANTENA", @"status": @"Estado não verificado"},
        @{@"title": @"HS PIKA", @"status": @"Estado não verificado"},
        @{@"title": @"HS CORPO 85", @"status": @"Estado não verificado"},
        @{@"title": @"144 FPS FFTH", @"status": @"Estado não verificado"}
    ];
    
    // Topo (Header)
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 80)];
    
    UIView *avatar = [[UIView alloc] initWithFrame:CGRectMake(20, 15, 50, 50)];
    avatar.backgroundColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    avatar.layer.cornerRadius = 25;
    UIImageView *personIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.fill"]];
    personIcon.tintColor = [UIColor whiteColor];
    personIcon.frame = CGRectMake(15, 15, 20, 20);
    [avatar addSubview:personIcon];
    [header addSubview:avatar];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(85, 15, 200, 30)];
    title.text = @"Patches";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:28];
    [header addSubview:title];
    
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(85, 45, 200, 20)];
    subtitle.text = @"V O L T   C H A T S";
    subtitle.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    subtitle.font = [UIFont boldSystemFontOfSize:12];
    [header addSubview:subtitle];
    
    [self.view addSubview:header];
    
    // Tabela de Patches
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 130, self.view.bounds.size.width, self.view.bounds.size.height - 220) style:UITableViewStylePlain];
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    // Barra inferior (Fake tab bar)
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 90, self.view.bounds.size.width, 90)];
    bottomBar.backgroundColor = [UIColor colorWithRed:0.08 green:0.02 blue:0.02 alpha:1.0];
    
    // Botão Patches ativo
    UIView *patchesBtn = [[UIView alloc] initWithFrame:CGRectMake(20, 15, 60, 50)];
    patchesBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.05 blue:0.05 alpha:1.0];
    patchesBtn.layer.cornerRadius = 10;
    UIImageView *pIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"scope"]];
    pIcon.tintColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    pIcon.frame = CGRectMake(20, 8, 20, 20);
    [patchesBtn addSubview:pIcon];
    UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 60, 15)];
    pLabel.text = @"Patches";
    pLabel.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    pLabel.font = [UIFont systemFontOfSize:10];
    pLabel.textAlignment = NSTextAlignmentCenter;
    [patchesBtn addSubview:pLabel];
    [bottomBar addSubview:patchesBtn];
    
    [self.view addSubview:bottomBar];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _patches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"PatchCell";
    PatchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PatchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *data = _patches[indexPath.row];
    cell.titleLabel.text = data[@"title"];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"? %@", data[@"status"]];
    
    [cell.toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    cell.toggle.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (void)toggleChanged:(UISwitch *)sender {
    NSString *patchName = _patches[sender.tag][@"title"];
    
    if (sender.isOn) {
        NSLog(@"Ativando patch: %@", patchName);
        // AQUI VAI A CHAMADA DO MOTOR DE INJEÇÃO DO 3105
        // [originalVC performSelector:NSSelectorFromString(@"injectPatchDirectoryWithDeviceIP:...")];
        
        // Simulação visual de carregamento
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Injetando" message:[NSString stringWithFormat:@"Ativando %@...", patchName] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        NSLog(@"Desativando patch: %@", patchName);
    }
}

@end

// --- INJETANDO A NOSSA TELA NO LUGAR DA ORIGINAL ---
%hook UIWindow
- (void)makeKeyAndVisible {
    originalVC = self.rootViewController; // Guarda a original
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *mainWindow = self;
        mainWindow.rootViewController = [[MyCustomVC alloc] init];
        [mainWindow makeKeyAndVisible];
    });
}
%end
