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
  static List<EquipmentItem> getWeaponsByTier(int tier) {
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
        return const [
          EquipmentItem(
            id: 'w_pipe_pistol',
            name: '9mm Pipe Pistol',
            type: ItemType.weapon,
            minStat: 9,
            maxStat: 15,
            scrapValue: 4,
            description: 'Crude firearm assembled from plumbing parts. Jams occasionally.',
          ),
          EquipmentItem(
            id: 'w_nailgun',
            name: 'Modified Nailgun',
            type: ItemType.weapon,
            minStat: 11,
            maxStat: 17,
            scrapValue: 5,
            description: 'Battery-powered pneumatic rammer firing hardened spikes.',
          ),
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

  static const List<ExpeditionContract> contracts = [
    ExpeditionContract(
      id: 'contract_clinic',
      title: 'ABANDONED CLINIC',
      subtitle: '2 Floors • Low Hazard • Standard Bounty',
      floorCount: 2,
      roomsPerFloor: 4,
      bountyMultiplier: 1,
      hazardLevel: 1,
    ),
    ExpeditionContract(
      id: 'contract_depot',
      title: 'INDUSTRIAL DEPOT',
      subtitle: '3 Floors • Moderate Hazard • Rich Salvage',
      floorCount: 3,
      roomsPerFloor: 4,
      bountyMultiplier: 1,
      hazardLevel: 2,
    ),
    ExpeditionContract(
      id: 'contract_blacksite',
      title: 'BLACK-SITE BUNKER',
      subtitle: '4 Floors • Lethal Threats • 2x Bounty Payout',
      floorCount: 4,
      roomsPerFloor: 4,
      bountyMultiplier: 2,
      hazardLevel: 3,
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
}
