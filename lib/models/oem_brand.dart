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
      brandName: 'Xiaomi / Poco / Redmi (MIUI & HyperOS)',
      logoIconName: 'xiaomi',
      steps: [
        'Open Security App -> Manage Apps -> OdoHUD.',
        'Enable "Autostart" and set to "Allow".',
        'Tap "Battery saver" -> Select "No restrictions".',
        'Lock OdoHUD in the Recent Apps switcher (padlock icon).',
      ],
      notes: 'MIUI aggressively kills GPS services after 5-10 minutes if restrictions are active.',
    ),
    OemBrand(
      brandName: 'Samsung (One UI)',
      logoIconName: 'samsung',
      steps: [
        'Settings -> Apps -> OdoHUD -> Battery.',
        'Select "Unrestricted" (do not use "Optimized").',
        'Settings -> Device Care -> Battery -> Background usage limits.',
        'Ensure OdoHUD is added to "Never auto-sleeping apps".',
      ],
      notes: 'Samsung sleeping apps feature suspends background location when screen turns off.',
    ),
    OemBrand(
      brandName: 'OnePlus / Oppo / Realme (ColorOS / OxygenOS)',
      logoIconName: 'oneplus',
      steps: [
        'Settings -> Battery -> Advanced settings -> Optimize battery use.',
        'Find OdoHUD and choose "Don\'t optimize".',
        'Settings -> Apps -> App management -> OdoHUD -> Battery usage.',
        'Enable "Allow background activity" and "Allow auto-launch".',
      ],
      notes: 'Deep optimization kills background telemetry sockets during rides.',
    ),
    OemBrand(
      brandName: 'Huawei / Honor (EMUI / MagicOS)',
      logoIconName: 'huawei',
      steps: [
        'Settings -> Battery -> App launch -> Find OdoHUD.',
        'Turn OFF "Manage automatically" and turn ON "Auto-launch", "Secondary launch", and "Run in background".',
      ],
      notes: 'PowerGenie terminates background services without warning unless manually exempted.',
    ),
    OemBrand(
      brandName: 'Google Pixel / Motorola / Stock Android',
      logoIconName: 'android',
      steps: [
        'Settings -> Apps -> See all apps -> OdoHUD -> App battery usage.',
        'Choose "Unrestricted".',
        'Ensure Location access is set to "Allow all the time".',
      ],
      notes: 'Standard Android allows ongoing foreground notifications with Unrestricted battery.',
    ),
  ];
}
