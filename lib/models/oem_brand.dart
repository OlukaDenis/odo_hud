class OemBrand {
  final String brandName;
  final String logoIconName;
  final List<String> steps;
  final String notes;

  const OemBrand({
    required this.brandName,
    required this.logoIconName,
    required this.steps,
    required this.notes,
  });

  static const List<OemBrand> supportedBrands = [
    OemBrand(
      brandName: 'Xiaomi / Poco / Redmi',
      logoIconName: 'xiaomi',
      steps: [
        'Open your Security app and tap Manage Apps -> OdoHUD.',
        'Turn on "Autostart".',
        'Tap "Battery saver" and pick "No restrictions".',
        'In your Recent Apps screen, lock OdoHUD with the padlock icon.',
      ],
      notes: 'MIUI and HyperOS can pause GPS tracking after a few minutes in the background unless Autostart and unrestricted battery are enabled.',
    ),
    OemBrand(
      brandName: 'Samsung Galaxy',
      logoIconName: 'samsung',
      steps: [
        'Go to Settings -> Apps -> OdoHUD -> Battery.',
        'Choose "Unrestricted" instead of "Optimized".',
        'Go to Settings -> Device Care -> Battery -> Background usage limits.',
        'Add OdoHUD to "Never auto-sleeping apps".',
      ],
      notes: 'Samsung automatically puts background apps to sleep when the screen turns off unless added to never-sleeping apps.',
    ),
    OemBrand(
      brandName: 'OnePlus / Oppo / Realme',
      logoIconName: 'oneplus',
      steps: [
        'Go to Settings -> Battery -> More settings -> Optimize battery use.',
        'Select OdoHUD and tap "Don\'t optimize".',
        'Go to Settings -> Apps -> App management -> OdoHUD -> Battery usage.',
        'Turn on both "Allow background activity" and "Allow auto-launch".',
      ],
      notes: 'ColorOS and OxygenOS close background GPS tasks to conserve battery unless auto-launch and background activity are turned on.',
    ),
    OemBrand(
      brandName: 'Huawei / Honor',
      logoIconName: 'huawei',
      steps: [
        'Go to Settings -> Battery -> App launch -> find OdoHUD.',
        'Turn off "Manage automatically".',
        'Turn on "Auto-launch", "Secondary launch", and "Run in background".',
      ],
      notes: 'EMUI and MagicOS close background services when the phone is locked unless manual launch settings are enabled.',
    ),
    OemBrand(
      brandName: 'Google Pixel / Motorola',
      logoIconName: 'android',
      steps: [
        'Go to Settings -> Apps -> OdoHUD -> App battery usage.',
        'Select "Unrestricted".',
        'Under Permissions -> Location, select "Allow all the time".',
      ],
      notes: 'Stock Android keeps the persistent notification and GPS active smoothly when battery usage is set to Unrestricted.',
    ),
  ];
}
