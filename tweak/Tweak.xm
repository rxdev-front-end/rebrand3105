#import <UIKit/UIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <objc/runtime.h>

static UIViewController *originalVC;
static NSString *const kPatchesKey = @"ImportedPatches3105";

Class findClassForSelector(SEL selector) {
    unsigned int count;
    Class *classes = objc_copyClassList(&count);
    Class result = nil;
    for (unsigned int i = 0; i < count; i++) {
        Class cls = classes[i];
        if (class_getInstanceMethod(cls, selector)) {
            result = cls;
            break;
        }
    }
    free(classes);
    return result;
}

@interface PatchItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) BOOL isActive;
@end

@implementation PatchItem
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"];
        _path = dict[@"path"];
        _isActive = [dict[@"isActive"] boolValue];
    }
    return self;
}
- (NSDictionary *)toDictionary {
    return @{@"name": _name ?: @"", @"path": _path ?: @"", @"isActive": @(_isActive)};
}
@end

@interface PatchCell : UITableViewCell
@property (nonatomic, strong) UIVisualEffectView *glassView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UISwitch *toggle;
@end

@implementation PatchCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _glassView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]];
        _glassView.layer.cornerRadius = 16;
        _glassView.layer.masksToBounds = YES;
        _glassView.layer.borderWidth = 1.0;
        _glassView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
        [self.contentView addSubview:_glassView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_glassView.contentView addSubview:_titleLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = [UIColor lightGrayColor];
        _statusLabel.font = [UIFont systemFontOfSize:13];
        [_glassView.contentView addSubview:_statusLabel];
        
        _toggle = [[UISwitch alloc] init];
        _toggle.onTintColor = [UIColor systemRedColor];
        [_glassView.contentView addSubview:_toggle];
        
        _glassView.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _toggle.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
            [_glassView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_glassView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_glassView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6],
            [_glassView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-6],
            
            [_titleLabel.leadingAnchor constraintEqualToAnchor:_glassView.contentView.leadingAnchor constant:20],
            [_titleLabel.topAnchor constraintEqualToAnchor:_glassView.contentView.topAnchor constant:16],
            [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_toggle.leadingAnchor constant:-10],
            
            [_statusLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_statusLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4],
            [_statusLabel.bottomAnchor constraintEqualToAnchor:_glassView.contentView.bottomAnchor constant:-16],
            
            [_toggle.centerYAnchor constraintEqualToAnchor:_glassView.contentView.centerYAnchor],
            [_toggle.trailingAnchor constraintEqualToAnchor:_glassView.contentView.trailingAnchor constant:-20]
        ]];
    }
    return self;
}
@end

@interface MyCustomVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<PatchItem *> *patches;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIDocumentPickerViewController *filePicker;
@end

@implementation MyCustomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.02 blue:0.02 alpha:1.0];
    
    [self loadData];
    [self setupUI];
}

- (void)loadData {
    _patches = [NSMutableArray array];
    NSArray *saved = [[NSUserDefaults standardUserDefaults] arrayForKey:kPatchesKey];
    for (NSDictionary *dict in saved) {
        [_patches addObject:[[PatchItem alloc] initWithDictionary:dict]];
    }
}

- (void)saveData {
    NSMutableArray *arr = [NSMutableArray array];
    for (PatchItem *item in _patches) {
        [arr addObject:[item toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:kPatchesKey];
}

- (void)setupUI {
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Patches";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:32];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:title];
    
    UIButton *importBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [importBtn setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
    importBtn.tintColor = [UIColor systemRedColor];
    importBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [importBtn addTarget:self action:@selector(importPatchTapped) forControlEvents:UIControlEventTouchUpInside];
    importBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:importBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.text = @"Nenhum patch importado.\nToque no + para adicionar.";
    _emptyLabel.textColor = [UIColor grayColor];
    _emptyLabel.font = [UIFont systemFontOfSize:16];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.numberOfLines = 0;
    _emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_emptyLabel];
    [self updateEmptyState];
    
    UIVisualEffectView *tabBarGlass = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark]];
    tabBarGlass.layer.cornerRadius = 25;
    tabBarGlass.layer.masksToBounds = YES;
    tabBarGlass.layer.borderWidth = 1.0;
    tabBarGlass.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    tabBarGlass.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tabBarGlass];
    
    UIStackView *tabContent = [[UIStackView alloc] init];
    tabContent.axis = UILayoutConstraintAxisVertical;
    tabContent.alignment = UIStackViewAlignmentCenter;
    tabContent.spacing = 4;
    tabContent.translatesAutoresizingMaskIntoConstraints = NO;
    [tabBarGlass.contentView addSubview:tabContent];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"scope"]];
    icon.tintColor = [UIColor systemRedColor];
    [icon.heightAnchor constraintEqualToConstant:24].active = YES;
    [icon.widthAnchor constraintEqualToConstant:24].active = YES;
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = @"Patches";
    lbl.textColor = [UIColor systemRedColor];
    lbl.font = [UIFont boldSystemFontOfSize:11];
    
    [tabContent addArrangedSubview:icon];
    [tabContent addArrangedSubview:lbl];
    
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [header.heightAnchor constraintEqualToConstant:50],
        
        [title.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [title.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        
        [importBtn.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [importBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        
        [_tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:10],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [_emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [tabBarGlass.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [tabBarGlass.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10],
        [tabBarGlass.widthAnchor constraintEqualToConstant:100],
        [tabBarGlass.heightAnchor constraintEqualToConstant:60],
        
        [tabContent.centerXAnchor constraintEqualToAnchor:tabBarGlass.contentView.centerXAnchor],
        [tabContent.centerYAnchor constraintEqualToAnchor:tabBarGlass.contentView.centerYAnchor]
    ]];
}

- (void)updateEmptyState {
    _emptyLabel.hidden = (_patches.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _patches.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"PatchCell";
    PatchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PatchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    PatchItem *item = _patches[indexPath.row];
    cell.titleLabel.text = item.name;
    cell.statusLabel.text = item.isActive ? @"Ativado" : @"Desativado";
    cell.toggle.on = item.isActive;
    cell.toggle.tag = indexPath.row;
    [cell.toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)toggleChanged:(UISwitch *)sender {
    PatchItem *item = _patches[sender.tag];
    item.isActive = sender.isOn;
    [self saveData];
    
    [self.tableView reloadData];
    
    if (item.isActive) {
        [self applyPatch:item];
    } else {
        [self restorePatch:item];
    }
}

// CORREÇÃO DO BOTÃO DE IMPORTAR
- (void)importPatchTapped {
    dispatch_async(dispatch_get_main_queue(), ^{
        // O asCopy:YES é a chave. Ele força o iOS a entregar o arquivo pra gente.
        self.filePicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];
        self.filePicker.delegate = self;
        [self presentViewController:self.filePicker animated:YES completion:nil];
    });
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    
    // Garante que a tela anterior já sumiu antes de abrir a caixinha de senha
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Senha do Patch" message:@"Digite a senha (ou deixe em branco)" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Senha...";
            textField.secureTextEntry = YES;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Importar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *password = alert.textFields.firstObject.text;
            [self processImport:url password:password];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)processImport:(NSURL *)url password:(NSString *)password {
    PatchItem *newItem = [[PatchItem alloc] init];
    newItem.name = url.lastPathComponent.stringByDeletingPathExtension;
    newItem.path = url.path;
    newItem.isActive = NO;
    
    [_patches addObject:newItem];
    [self saveData];
    [self.tableView reloadData];
    [self updateEmptyState];
}

- (void)applyPatch:(PatchItem *)item {
    NSLog(@"[MinhaApp] Aplicando patch: %@ no caminho: %@", item.name, item.path);
    
    SEL injectSel = NSSelectorFromString(@"injectDirectoryWithDeviceIP:pairingPath:sourceDirectory:targetDirectory:directoryName:error:");
    Class targetClass = findClassForSelector(injectSel);
    
    if (targetClass) {
        NSLog(@"[MinhaApp] SUCESSO! Encontrei a classe do motor: %@", NSStringFromClass(targetClass));
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Motor Encontrado" message:[NSString stringWithFormat:@"Classe: %@\nInjetando %@...", NSStringFromClass(targetClass), item.name] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        NSLog(@"[MinhaApp] Falha ao encontrar o motor.");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erro" message:@"Não achei o motor de injeção do app." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)restorePatch:(PatchItem *)item {
    NSLog(@"[MinhaApp] Restaurando patch: %@", item.name);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restaurando" message:[NSString stringWithFormat:@"Removendo %@...", item.name] preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

@end

%hook UIWindow
- (void)makeKeyAndVisible {
    originalVC = self.rootViewController;
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *mainWindow = self;
        mainWindow.rootViewController = [[MyCustomVC alloc] init];
        [mainWindow makeKeyAndVisible];
    });
}
%end
