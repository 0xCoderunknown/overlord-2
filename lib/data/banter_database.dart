typedef BanterPair = ({String enemy, String hero});

class BanterDatabase {
  BanterDatabase._();

  static const BanterPair turkeyOpening = (
    enemy: '...Truce?',
    hero: 'Did that naked turkey just ask for a truce?! ...Nah, eat lead.',
  );

  static const List<BanterPair> animalRound1 = [
    (
      enemy: 'Peace...?',
      hero: 'Wait—did it just say "peace"?! Sorry pal, shooting anyway.',
    ),
    (
      enemy: '.....',
      hero: 'Did it just stare at me in Morse code? Light \'em up!',
    ),
    (
      enemy: 'Hugs?',
      hero: 'I don\'t hug things with three rows of teeth. Eat lead!',
    ),
  ];

  static const List<BanterPair> animalRound2 = [
    (
      enemy: 'Friend?',
      hero: 'You just bit my boot! Worst diplomat ever.',
    ),
    (
      enemy: '......',
      hero: 'Still the strong, silent type? Fine, talk to my barrel.',
    ),
    (
      enemy: 'Taxes...',
      hero: 'Even mutated beasts collect taxes?! Yeah, no.',
    ),
  ];

  static const BanterPair animalLowHp = (
    enemy: 'Mercy...?',
    hero: 'Now you speak English?! Still shooting, sorry!',
  );

  static const BanterPair animalRound3 = (
    enemy: 'Bananas.',
    hero: 'Great. I\'m in a firefight with a lunatic mutant.',
  );

  static const List<BanterPair> humanRound1 = [
    (
      enemy: 'Empty your pack, vault rat!',
      hero: 'How about you empty your pockets first?',
    ),
    (
      enemy: 'Wrong door to kick in, scavenger.',
      hero: 'Funny, I was about to say the exact same thing.',
    ),
    (
      enemy: 'Fresh meat! Stay right there!',
      hero: 'Bad news, pal—I shoot back.',
    ),
  ];

  static const List<BanterPair> humanRound2 = [
    (
      enemy: 'That scrap armor won\'t save you!',
      hero: 'Saved me just fine so far!',
    ),
    (
      enemy: 'Stop dodging, vault-boy!',
      hero: 'Not how a gunfight works, buddy!',
    ),
  ];

  static const BanterPair humanLowHp = (
    enemy: 'You\'re bleeding out! Drop the gun!',
    hero: 'Still breathing... that\'s all I need!',
  );

  static const BanterPair humanRound3 = (
    enemy: 'Why won\'t you just drop?!',
    hero: 'Too stubborn. Ask the guys downstairs.',
  );

  static const BanterPair robotRound1 = (
    enemy: '[INTRUDER DETECTED. LETHAL FORCE.]',
    hero: 'Tell your programmer I have a visitor pass!',
  );

  static const BanterPair robotRound2 = (
    enemy: '[TARGET PERSISTS. RECALIBRATING.]',
    hero: 'Recalibrate this, tin can!',
  );

  static const BanterPair robotLowHp = (
    enemy: '[HOSTILE VITALITY CRITICAL. PREPARING MOP.]',
    hero: 'A mop?! Oh, that\'s cold, tin can!',
  );

  static const BanterPair robotRound3 = (
    enemy: '[BATTERY CRITICAL. OVERDRIVE.]',
    hero: 'Just short-circuit already!',
  );

  static const BanterPair bossRound1 = (
    enemy: 'YOU GOT A DEATH WISH, VAULT RAT? PUNISH TIME!',
    hero: 'Whoa... big guy, tiny temper. Steady, Vance.',
  );

  static const BanterPair bossRound2 = (
    enemy: 'ANGRY NOW! SMASH YOU LIKE THE OTHERS!',
    hero: 'Yeah, yeah—less talking, more dodging!',
  );

  static const BanterPair bossLowHp = (
    enemy: 'ONE MORE SWING AND YOU\'RE PASTE!',
    hero: 'Bleeding out... come on, one clean shot!',
  );

  static const BanterPair bossRound3 = (
    enemy: 'NO ONE WALKS OUT OF MY ROOF!',
    hero: 'Funny. Watch me walk.',
  );

  static const List<BanterPair> ghoulRound1 = [
    (
      enemy: '*Gurgle...* "...peace?"',
      hero: 'Peace?! You\'re literally chewing on a lead pipe! Eat this!',
    ),
    (
      enemy: '*Rattling hiss...* "Hug?"',
      hero: 'Hard pass on the radiation cuddle, pal!',
    ),
  ];

  static const List<BanterPair> ghoulRound2 = [
    (
      enemy: '*Frenzied snarling...* "Rent?"',
      hero: 'Not paying rent to a pack of ghouls!',
    ),
  ];

  static const BanterPair ghoulLowHp = (
    enemy: '*Hungry clawing...* "Snack..."',
    hero: 'Not becoming ghoul chow today!',
  );

  static const BanterPair ghoulRound3 = (
    enemy: '*Raspy screech...* "Salad?"',
    hero: 'Did it just ask for a salad?! Just stay down!',
  );

  static const List<String> emptyScrapQuips = [
    '"Nothing but rusted tins and rat droppings."',
    '"Picked clean already. Waste of time."',
    '"Just bent metal and ash."',
    '"Empty. Better luck in the next room."',
  ];

  static const List<String> overseerQuips = [
    '"Vault 42 air filters at 64%. Try not to get Vance eaten."',
    '"Reminder: Mutated rats are NOT Vault-Tec approved pets."',
    '"Caps keep the lights on. Bring back something shiny."',
    '"Radio check: Surface radiation nominal. Which means lethal."',
  ];
}
