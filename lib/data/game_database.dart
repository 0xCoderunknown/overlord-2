import '../domain/models.dart';

class GameDatabase {
  GameDatabase._();

  // -------------------------------------------------------------
  // BESTIARY (TIER 1 TO TIER 4 APEX BOSSES)
  // -------------------------------------------------------------
  static List<Enemy> getTier1Enemies() => [
        Enemy(
          name: 'Mutated Rat',
          maxHp: 16,
          minDamage: 3,
          maxDamage: 6,
          bountyGold: 8,
          description: 'Ankle-biters the size of a bulldog. Ravenous and quick.',
        ),
        Enemy(
          name: 'Feral Hound',
          maxHp: 22,
          minDamage: 4,
          maxDamage: 8,
          bountyGold: 12,
          description: 'Fast, erratic, and snaps straight for unarmored limbs.',
        ),
      ];

  static List<Enemy> getTier2Enemies() => [
        Enemy(
          name: 'Desperate Scrapper',
          maxHp: 30,
          minDamage: 6,
          maxDamage: 11,
          bountyGold: 16,
          description: 'Swinging heavy lead pipes. Desperation makes them reckless.',
        ),
        Enemy(
          name: 'Raider Enforcer',
          maxHp: 38,
          minDamage: 8,
          maxDamage: 14,
          bountyGold: 22,
          description: 'Carries a crude shotgun. Heavy armor recommended.',
        ),
      ];

  static List<Enemy> getTier3Enemies() => [
        Enemy(
          name: 'Security Drone',
          maxHp: 48,
          minDamage: 12,
          maxDamage: 18,
          bountyGold: 30,
          description: 'Pre-war automated patrol drone. Cold and laser-accurate.',
        ),
        Enemy(
          name: 'Feral Ghoul Pack',
          maxHp: 44,
          minDamage: 10,
          maxDamage: 16,
          bountyGold: 26,
          description: 'Irradiated human remnants attacking in manic bursts.',
        ),
      ];

  static List<Enemy> getApexBosses() => [
        Enemy(
          name: 'Featherless Turkey',
          maxHp: 75,
          minDamage: 16,
          maxDamage: 24,
          bountyGold: 75,
          isBoss: true,
          description: 'Apex wasteland predator. It knows martial arts. May God have mercy.',
        ),
        Enemy(
          name: 'Pre-War Battlemech',
          maxHp: 90,
          minDamage: 18,
          maxDamage: 28,
          bountyGold: 100,
          isBoss: true,
          description: 'Heavy military security titan with malfunctioning target arrays.',
        ),
        Enemy(
          name: 'Irradiated Behemoth',
          maxHp: 85,
          minDamage: 15,
          maxDamage: 26,
          bountyGold: 90,
          isBoss: true,
          description: 'A hulking mass of irradiated muscle and rusted scrap plates.',
        ),
      ];

  // -------------------------------------------------------------
  // WEAPONS (TIER 1 TO TIER 3)
  // -------------------------------------------------------------
  static const EquipmentItem nailStuddedBat = EquipmentItem(
    id: 'w_nail_bat',
    name: 'Nail-Studded Bat',
    type: ItemType.weapon,
    minStat: 13,
    maxStat: 20,
    scrapValue: 6,
    description: 'Unlocked slugger special. Tears through rodents.',
  );

  static List<EquipmentItem> getWeaponsByTier(
    int tier, {
    Set<String> unlockedIds = const {},
  }) {
    switch (tier) {
      case 1:
        return const [
          EquipmentItem(
            id: 'w_stapler',
            name: 'Heavy Duty Staple Gun',
            type: ItemType.weapon,
            minStat: 5,
            maxStat: 9,
            scrapValue: 2,
            description: 'Requires getting close. Good for vermin, poor against armor.',
          ),
          EquipmentItem(
            id: 'w_rebar',
            name: 'Rusted Rebar Club',
            type: ItemType.weapon,
            minStat: 7,
            maxStat: 12,
            scrapValue: 3,
            description: 'A classic argument settler with dried blood on the heavy end.',
          ),
        ];
      case 2:
        return [
          const EquipmentItem(
            id: 'w_pipe_pistol',
            name: '9mm Pipe Pistol',
            type: ItemType.weapon,
            minStat: 9,
            maxStat: 15,
            scrapValue: 4,
            description: 'Crude firearm assembled from plumbing parts. Jams occasionally.',
          ),
          const EquipmentItem(
            id: 'w_nailgun',
            name: 'Modified Nailgun',
            type: ItemType.weapon,
            minStat: 11,
            maxStat: 17,
            scrapValue: 5,
            description: 'Battery-powered pneumatic rammer firing hardened spikes.',
          ),
          if (unlockedIds.contains('unlock_bat')) nailStuddedBat,
        ];
      case 3:
      default:
        return const [
          EquipmentItem(
            id: 'w_service_rifle',
            name: 'Pre-War Service Rifle',
            type: ItemType.weapon,
            minStat: 16,
            maxStat: 26,
            scrapValue: 10,
            description: 'Pristine military rifle. Heavy ballistic punch.',
          ),
          EquipmentItem(
            id: 'w_plasma_torch',
            name: 'Industrial Plasma Torch',
            type: ItemType.weapon,
            minStat: 22,
            maxStat: 34,
            scrapValue: 15,
            description: 'Bulk steel cutter that disintegrates organic targets.',
          ),
        ];
    }
  }

  // -------------------------------------------------------------
  // ARMOR (TIER 1 TO TIER 3)
  // -------------------------------------------------------------
  static List<EquipmentItem> getArmorsByTier(int tier) {
    switch (tier) {
      case 1:
        return const [
          EquipmentItem(
            id: 'arm_phonebook',
            name: 'Taped Phonebook Vest',
            type: ItemType.armor,
            minStat: 2,
            maxStat: 4,
            scrapValue: 2,
            description: 'Yellow pages bound tightly with industrial duct tape.',
          ),
          EquipmentItem(
            id: 'arm_leather',
            name: 'Boiled Leather Apron',
            type: ItemType.armor,
            minStat: 3,
            maxStat: 6,
            scrapValue: 3,
            description: 'Deflects glancing mutant bites and flying shrapnel.',
          ),
        ];
      case 2:
        return const [
          EquipmentItem(
            id: 'arm_moto',
            name: 'Motorcycle Leathers',
            type: ItemType.armor,
            minStat: 5,
            maxStat: 9,
            scrapValue: 5,
            description: 'Reinforced with tire chains and highway road signs.',
          ),
          EquipmentItem(
            id: 'arm_scrap',
            name: 'Welded Scrap Plate',
            type: ItemType.armor,
            minStat: 7,
            maxStat: 12,
            scrapValue: 7,
            description: 'Solid corrugated steel plate protecting vital organs.',
          ),
        ];
      case 3:
      default:
        return const [
          EquipmentItem(
            id: 'arm_riot',
            name: 'Pre-War Riot Suit',
            type: ItemType.armor,
            minStat: 11,
            maxStat: 18,
            scrapValue: 12,
            description: 'Composite ceramic chestplate with built-in ballistic gel.',
          ),
          EquipmentItem(
            id: 'arm_power_frame',
            name: 'Scrap-Iron Power Frame',
            type: ItemType.armor,
            minStat: 15,
            maxStat: 24,
            scrapValue: 20,
            description: 'Motorized exoskeleton rig shrugging off small-arms fire.',
          ),
        ];
    }
  }

  // -------------------------------------------------------------
  // CONSUMABLES
  // -------------------------------------------------------------
  static const List<EquipmentItem> consumables = [
    EquipmentItem(
      id: 'c_medkit',
      name: 'Wasteland Trauma Medkit',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.heal,
      scrapValue: 3,
      description: 'Sterile coagulant injectors restoring +50 HP.',
    ),
    EquipmentItem(
      id: 'c_psycho',
      name: 'Combat Psycho Chem',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.psycho,
      scrapValue: 4,
      description: 'Violent adrenaline stim granting +6 DMG in battle.',
    ),
    EquipmentItem(
      id: 'c_stealthboy',
      name: 'Stealthboy Cloak Unit',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.stealth,
      scrapValue: 5,
      description: 'Reflective light-bending module allowing silent passage.',
    ),
    EquipmentItem(
      id: 'c_key',
      name: 'Security Master Key',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.key,
      scrapValue: 3,
      description: 'Brass master key used to breach reinforced vault safes.',
    ),
  ];

  static const List<EquipmentItem> craftingMaterials = [
    EquipmentItem(
      id: 'med_syringe',
      name: 'Used Syringe',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.material,
      scrapValue: 1,
      description: 'Medical salvage used in Medbay Medkit synthesis.',
    ),
    EquipmentItem(
      id: 'med_herb',
      name: 'Irradiated Herb',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.material,
      scrapValue: 2,
      description: 'Medicinal flora used in Medbay Medkit synthesis.',
    ),
    EquipmentItem(
      id: 'chem_expired',
      name: 'Expired Chemicals',
      type: ItemType.consumable,
      consumableEffect: ConsumableEffect.material,
      scrapValue: 3,
      description: 'Pre-war reagents used in Medbay Medkit synthesis.',
    ),
  ];

  static const EquipmentItem burialCloth = EquipmentItem(
    id: 'mat_burial_cloth',
    name: 'Burial Cloth',
    type: ItemType.consumable,
    consumableEffect: ConsumableEffect.material,
    scrapValue: 4,
    description:
        'Clean linen shroud required by Vault Regs to wrap fallen scouts.',
  );

  static const List<EquipmentItem> foods = [
    EquipmentItem(
      id: 'f_purified_water',
      name: 'Purified Water',
      type: ItemType.consumable,
      minStat: 15,
      maxStat: 0,
      consumableEffect: ConsumableEffect.food,
      scrapValue: 2,
      description: 'Clean, cold, and zero glow. Restores +15 HP out of combat.',
    ),
    EquipmentItem(
      id: 'f_dog_food',
      name: 'Canned Dog Food',
      type: ItemType.consumable,
      minStat: 10,
      maxStat: 0,
      consumableEffect: ConsumableEffect.food,
      scrapValue: 1,
      description: 'Tastes better than it smells. Restores +10 HP out of combat.',
    ),
    EquipmentItem(
      id: 'f_rad_radish',
      name: 'Rad-Radish',
      type: ItemType.consumable,
      minStat: 12,
      maxStat: 25,
      consumableEffect: ConsumableEffect.food,
      scrapValue: 1,
      description: 'Spicy & glowing. +12 HP, 25% rad-burn risk.',
    ),
    EquipmentItem(
      id: 'f_dirty_water',
      name: 'Dirty Water',
      type: ItemType.consumable,
      minStat: 8,
      maxStat: 35,
      consumableEffect: ConsumableEffect.food,
      scrapValue: 1,
      description: 'Rust and regret. +8 HP, 35% sickness risk.',
    ),
    EquipmentItem(
      id: 'f_spoiled_meat',
      name: 'Spoiled Canned Meat',
      type: ItemType.consumable,
      minStat: 15,
      maxStat: 40,
      consumableEffect: ConsumableEffect.food,
      scrapValue: 1,
      description: 'Questionable vintage. +15 HP, 40% food poisoning risk.',
    ),
  ];

  static const List<ChallengeDef> challenges = [
    ChallengeDef(
      id: 'unlock_bat',
      title: 'SLUGGER INITIATE',
      description: 'Defeat 5 hostiles across runs',
      statKey: 'kills',
      targetCount: 5,
      rewardLabel: 'Unlocks Nail-Studded Bat in loot pool',
    ),
    ChallengeDef(
      id: 'unlock_cat',
      title: 'RAT EXTERMINATOR',
      description: 'Defeat 15 Mutated Rats',
      statKey: 'rats',
      targetCount: 15,
      rewardLabel: 'Unlocks Alley Cat playable starter',
    ),
    ChallengeDef(
      id: 'unlock_sparky',
      title: 'APEX SURVIVOR',
      description: 'Defeat 1 Apex Boss',
      statKey: 'bosses',
      targetCount: 1,
      rewardLabel: 'Unlocks Sparky (Battery Set) & Plasma Torch drops',
    ),
  ];

  static const List<ScoutStarter> starters = [
    ScoutStarter(
      id: 'starter_vance',
      name: 'Vance',
      title: 'Vault Scout',
      bio: 'Veteran Bunker 42 infiltrator. Never leaves home without his rusted pipe pistol.',
      portraitAsset: 'assets/images/hero.png',
      maxHp: 100,
      weapon: EquipmentItem(
        id: 'wpn_pipe_pistol',
        name: 'Crude Pipe Pistol',
        type: ItemType.weapon,
        minStat: 6,
        maxStat: 12,
        scrapValue: 2,
        description: 'Rusted chamber. Shoots scrap rivets.',
      ),
      armor: EquipmentItem(
        id: 'arm_phonebook',
        name: 'Taped Phonebook',
        type: ItemType.armor,
        minStat: 2,
        maxStat: 4,
        scrapValue: 2,
        description: 'Layers of yellow pages bound by duct tape.',
      ),
    ),
    ScoutStarter(
      id: 'char_shina',
      name: 'Shina',
      title: 'Agile Scout',
      bio: 'Squishy but fast. Prefers light leather and sneaking past trouble.',
      portraitAsset: 'assets/images/char/jonny.webp',
      maxHp: 80,
      weapon: EquipmentItem(
        id: 'w_stapler',
        name: 'Heavy Staple Gun',
        type: ItemType.weapon,
        minStat: 5,
        maxStat: 11,
        scrapValue: 2,
        description: 'Squishy scout, snappy makeshift sidearm.',
      ),
      armor: EquipmentItem(
        id: 'a_leather',
        name: 'Boiled Leather',
        type: ItemType.armor,
        minStat: 2,
        maxStat: 5,
        scrapValue: 2,
        description: 'Light leather deflecting minor bites.',
      ),
    ),
    ScoutStarter(
      id: 'char_drifter',
      name: 'Drifter',
      title: 'Wasteland Scavenger',
      bio: 'Balanced wasteland scavenger. Keeps their head down and swings hard.',
      portraitAsset: 'assets/images/char/jonny.webp',
      maxHp: 100,
      weapon: EquipmentItem(
        id: 'w_rebar',
        name: 'Rusted Rebar Club',
        type: ItemType.weapon,
        minStat: 7,
        maxStat: 12,
        scrapValue: 3,
        description: 'Classic argument settler with dried blood.',
      ),
      armor: EquipmentItem(
        id: 'arm_phonebook',
        name: 'Taped Phonebook',
        type: ItemType.armor,
        minStat: 2,
        maxStat: 4,
        scrapValue: 2,
        description: 'Layers of yellow pages bound by duct tape.',
      ),
    ),
    ScoutStarter(
      id: 'char_robot',
      name: 'Sentry Bot',
      title: 'Heavy Automaton',
      bio: 'Tanky pre-war automaton built for surviving irradiated sectors.',
      portraitAsset: 'assets/images/char/overseer.webp',
      maxHp: 150,
      weapon: EquipmentItem(
        id: 'wpn_battery',
        name: 'Car Battery Set',
        type: ItemType.weapon,
        minStat: 4,
        maxStat: 15,
        scrapValue: 3,
        description: 'Wild voltage arcs. Tanky chassis.',
      ),
      armor: EquipmentItem(
        id: 'a_scrap_plate',
        name: 'Welded Scrap Plate',
        type: ItemType.armor,
        minStat: 4,
        maxStat: 7,
        scrapValue: 4,
        description: 'Heavy bolted iron plating.',
      ),
    ),
    ScoutStarter(
      id: 'starter_cat',
      name: 'Alley Cat',
      title: 'Feral Striker',
      bio: 'Feral mutant alley cat with razor claws. Unlocked by hunting 15 Mutated Rats.',
      portraitAsset: 'assets/images/hero.png',
      maxHp: 90,
      unlockChallengeId: 'unlock_cat',
      weapon: EquipmentItem(
        id: 'wpn_claws',
        name: 'Razor Claws',
        type: ItemType.weapon,
        minStat: 8,
        maxStat: 13,
        scrapValue: 3,
        description: 'Fast, vicious, and doesn\'t jam.',
      ),
      armor: EquipmentItem(
        id: 'arm_fur',
        name: 'Matted Thick Fur',
        type: ItemType.armor,
        minStat: 1,
        maxStat: 4,
        scrapValue: 1,
        description: 'Lighter than scrap, surprisingly tough.',
      ),
    ),
  ];

  static const List<ExpeditionContract> contracts = [
    ExpeditionContract(
      id: 'contract_clinic',
      title: 'ABANDONED CLINIC',
      subtitle: '2 Floors • Low Hazard • Standard Bounty',
      floorCount: 2,
      roomsPerFloor: 4,
      bountyMultiplier: 1,
      hazardLevel: 1,
      lootFocus: 'MEDBAY SCRAP & SYRINGES',
    ),
    ExpeditionContract(
      id: 'contract_depot',
      title: 'INDUSTRIAL DEPOT',
      subtitle: '3 Floors • Moderate Hazard • Rich Salvage',
      floorCount: 3,
      roomsPerFloor: 4,
      bountyMultiplier: 1,
      hazardLevel: 2,
      lootFocus: 'WEAPONS, ARMOR & XP',
    ),
    ExpeditionContract(
      id: 'contract_haunted',
      title: 'HAUNTED HOME',
      subtitle: '3 Floors • Cursed Threats • Burial Cloth Drops',
      floorCount: 3,
      roomsPerFloor: 4,
      bountyMultiplier: 1,
      hazardLevel: 2,
      lootFocus: 'BURIAL CLOTH & CURSED LOOT',
    ),
    ExpeditionContract(
      id: 'contract_blacksite',
      title: 'BLACK-SITE BUNKER',
      subtitle: '4 Floors • Lethal Threats • 2x Bounty Payout',
      floorCount: 4,
      roomsPerFloor: 4,
      bountyMultiplier: 2,
      hazardLevel: 3,
      lootFocus: '2X COINS & APEX THREATS',
    ),
  ];

  // -------------------------------------------------------------
  // ATMOSPHERIC EMPTY-ROOM LORE (FALLOUT, STALKER, RE, DARK SOULS)
  // -------------------------------------------------------------
  static const List<String> emptyRoomLore = [
    'The radiation meter is clicking rhythmically... like a nervous heartbeat.',
    'Found an old blue jumpsuit with the number 101 on the back.',
    'A faded poster shows a smiling boy giving a thumbs up. Too cheerful for this world.',
    'Someone scrawled on the concrete wall: "4 / Itchy / Tasty".',
    'A small pile of ash in the corner with a rusted iron coil. A strange warmth lingers.',
    'A bloody warning on the rusted door: "Don\'t open, Dead inside".',
    'Faint static whispers from a cracked PA speaker: "Would you kindly...?"',
    'Found a gas mask filter clogged with ash and ancient memories.',
    'The silence inside these concrete walls is louder than gunfire.',
    'Patrolling these ruins almost makes you wish for a nuclear winter.',
    'An empty soda bottle sits on the desk. The bottle cap is the only valuable part.',
    'Someone carved tally marks into the doorframe. They stop at forty-two.',
  ];

  static const List<String> clinicLore = [
    'Shattered med-vials crunch under my boots.',
    'An old triage chart still hangs on the rusted clipboard.',
    'Smells like stale antiseptic and copper.',
  ];

  static const List<String> generatorLore = [
    'Dead coolant pipes drip rhythmically into the grate.',
    'The radiation meter ticks faster near the blown fuses.',
    'Ozone and scorched wiring hang heavy in the air.',
  ];

  static const List<String> officeLore = [
    'A pre-war terminal blinks an amber cursor: NO SIGNAL.',
    'Desk drawers pulled wide open. Nothing left but ash.',
    'Found a dusty coffee mug beside a skeleton in a tie.',
  ];

  static const List<String> storageLore = [
    'Toppled steel shelving blocks half the wall.',
    'Empty crate stencils: VAULT-TEC RATION PACKS.',
    'Rusted padlock snapped off a long time ago.',
  ];

  static const List<String> hauntedLore = [
    'Cold air seeps through wallpaper peeling like dead skin.',
    'A child\'s rocking chair creaks on its own in the corner.',
    'Moth-eaten funeral linens hang neatly in the closet.',
    'Someone wrote "DO NOT BURY THEM HERE" behind the mirror.',
  ];

  static List<String> getIndoorLorePool(
    RoomType type, {
    bool isHaunted = false,
  }) {
    if (isHaunted) return hauntedLore;
    return switch (type) {
      RoomType.clinic => clinicLore,
      RoomType.generator => generatorLore,
      RoomType.office => officeLore,
      RoomType.storage => storageLore,
      _ => [
          ...emptyRoomLore,
          'Dust motes drift through a cracked ceiling vent.',
          'Faint scratching behind the bulkhead... probably just pipes.',
        ],
    };
  }
}
