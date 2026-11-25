typedef BanterPair = ({String enemy, String hero});

class BanterDatabase {
  BanterDatabase._();

  static const BanterPair turkeyOpening = (
    enemy: '.....',
    hero: 'Wait... is that a featherless turkey doing kung fu?!',
  );

  static const List<BanterPair> animalRound1 = [
    (enemy: '.....', hero: 'Did it just stare at me in Morse code?'),
    (enemy: '.....', hero: 'Look buddy, I don\'t speak mutant.'),
    (enemy: '.....', hero: 'Uh... was that a threat or a sneeze?'),
  ];

  static const List<BanterPair> animalRound2 = [
    (enemy: '......', hero: 'Still the strong silent type? Fine, eat lead.'),
    (enemy: '......', hero: 'Stop staring like that, it\'s creeping me out!'),
    (enemy: '......', hero: 'No talking? Cool. My gun does the chatting.'),
  ];

  static const BanterPair animalLowHp = (
    enemy: '.....',
    hero: 'Okay, silent AND vicious! Need to end this fast!',
  );

  static const BanterPair animalRound3 = (
    enemy: '.....',
    hero: 'I\'m losing an argument with a mutated beast. Great.',
  );

  static const List<BanterPair> humanRound1 = [
    (
      enemy: 'Empty your pack, vault rat!',
      hero: 'How about you empty your pockets first?',
    ),
    (
      enemy: 'Wrong door to kick in, scavenger.',
      hero: 'Funny, I was about to say the same thing.',
    ),
    (
      enemy: 'Fresh meat! Stay right there!',
      hero: 'Tough luck. I\'m past my expiration date.',
    ),
  ];

  static const List<BanterPair> humanRound2 = [
    (
      enemy: 'That armor won\'t save you!',
      hero: 'Saved me just fine so far!',
    ),
    (
      enemy: 'Hold still so I can hit you!',
      hero: 'Not how this works, pal!',
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
    enemy: '[TARGET PERSISTS. RECALIBRATING.]',
    hero: 'Ow! Okay, recalibrate someone else!',
  );

  static const BanterPair robotRound3 = (
    enemy: '[BATTERY CRITICAL. OVERDRIVE.]',
    hero: 'Just short-circuit already!',
  );

  static const BanterPair bossRound1 = (
    enemy: 'YOU MADE IT THIS FAR. YOU WON\'T LEAVE.',
    hero: 'Whoa... now that\'s a big problem. Steady, Vance.',
  );

  static const BanterPair bossRound2 = (
    enemy: 'IS THAT ALL YOUR SCRAP GUN CAN DO?',
    hero: 'Just warming up, big guy!',
  );

  static const BanterPair bossLowHp = (
    enemy: 'IS THAT ALL YOUR SCRAP GUN CAN DO?',
    hero: 'Bleeding out... come on, one clean shot!',
  );

  static const BanterPair bossRound3 = (
    enemy: 'END OF THE LINE, SCAVENGER.',
    hero: 'Funny. I was just thinking the exact same thing.',
  );

  static const List<String> emptyScrapQuips = [
    '"Nothing but rusted tins and rat droppings."',
    '"Picked clean already. Waste of time."',
    '"Just bent metal and ash."',
    '"Empty. Better luck in the next room."',
  ];
}
