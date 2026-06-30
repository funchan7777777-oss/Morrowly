import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';

abstract final class CapsuleArtwork {
  static const threadUnderline =
      'assets/morrowly_art/ui/morrowly_ui_thread.png';
  static const actionOrbit = 'assets/morrowly_art/ui/morrowly_ui_orbit.png';
  static const actionFeather = 'assets/morrowly_art/ui/morrowly_ui_nova.png';
  static const capsuleCoin = 'assets/morrowly_art/ui/morrowly_ui_capsule.png';
  static const heroJar = 'assets/morrowly_art/ui/morrowly_ui_dream.png';
  static const previewWash = 'assets/morrowly_art/ui/morrowly_ui_recall.png';
  static const sealedPostcard =
      'assets/morrowly_art/ui/morrowly_ui_postcard.png';
  static const dialogPrelude = 'assets/morrowly_art/ui/morrowly_ui_prelude.png';
  static const capsuleTypeLetter =
      'assets/morrowly_art/ui/morrowly_ui_glimpse.png';
  static const capsuleTypeVideo =
      'assets/morrowly_art/ui/morrowly_ui_reminisce.png';
  static const customTimeGlyph =
      'assets/morrowly_art/ui/morrowly_ui_memento.png';
  static const bloomMark = 'assets/morrowly_art/ui/morrowly_ui_bloom.png';
  static const museMark = 'assets/morrowly_art/ui/morrowly_ui_muse.png';
  static const sayButton = 'assets/morrowly_art/ui/morrowly_ui_spark.png';
  static const myCapsulesSmall =
      'assets/morrowly_art/ui/morrowly_ui_reunion.png';
  static const viewCapsules = 'assets/morrowly_art/ui/morrowly_ui_locket.png';
  static const confirmSeal = 'assets/morrowly_art/ui/morrowly_ui_heartbeat.png';
  static const sealedCapsules =
      'assets/morrowly_art/ui/morrowly_ui_yesterday.png';
  static const confirmButton =
      'assets/morrowly_art/ui/morrowly_ui_duskfall.png';
  static const backHome = 'assets/morrowly_art/ui/morrowly_ui_presence.png';
  static const publicChip = 'assets/morrowly_art/ui/morrowly_ui_evermore.png';
  static const privateChip = 'assets/morrowly_art/ui/morrowly_ui_anchor.png';
  static const checkChip = 'assets/morrowly_art/ui/morrowly_ui_gather.png';
  static const deleteChip = 'assets/morrowly_art/ui/morrowly_ui_bond.png';
}

abstract final class CapsuleSquareSeed {
  static const currentKeeper = CapsuleKeeper(
    keeperId: 'self-rainlit-room',
    publicName: 'Mira Vale',
    ageMark: '24',
    homeRegion: 'United States',
    signalBand: KeeperSignalBand.bloom,
    portraitAsset: '',
  );

  static const bloomKeepers = [
    CapsuleKeeper(
      keeperId: 'bloom-arch-window',
      publicName: 'Carolyn Massey',
      ageMark: '23',
      homeRegion: 'Australia',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_arch_window.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-cedar-terrace',
      publicName: 'Elara Finch',
      ageMark: '22',
      homeRegion: 'Canada',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_cedar_terrace.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-sunlit-step',
      publicName: 'Nora Wells',
      ageMark: '25',
      homeRegion: 'Ireland',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_sunlit_step.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-hill-path',
      publicName: 'Livia Rowe',
      ageMark: '21',
      homeRegion: 'New Zealand',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_hill_path.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-morning-arch',
      publicName: 'Arielle Knox',
      ageMark: '24',
      homeRegion: 'France',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_morning_arch.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-campus-courtyard',
      publicName: 'Sofia Marin',
      ageMark: '20',
      homeRegion: 'Spain',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_campus_courtyard.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-evening-room',
      publicName: 'Maya Sterling',
      ageMark: '26',
      homeRegion: 'United States',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_evening_room.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-cafe-awning',
      publicName: 'Kira Ashby',
      ageMark: '23',
      homeRegion: 'Italy',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_cafe_awning.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-soft-corner',
      publicName: 'Ivy Monroe',
      ageMark: '22',
      homeRegion: 'Netherlands',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_soft_corner.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-gold-room',
      publicName: 'June Calder',
      ageMark: '24',
      homeRegion: 'United Kingdom',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_gold_room.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-clear-window',
      publicName: 'Sienna Vale',
      ageMark: '25',
      homeRegion: 'Sweden',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_clear_window.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-lake-glow',
      publicName: 'Talia Arden',
      ageMark: '21',
      homeRegion: 'Switzerland',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_lake_glow.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-blonde-lane',
      publicName: 'Rhea Collins',
      ageMark: '24',
      homeRegion: 'Denmark',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_blonde_lane.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-pine-light',
      publicName: 'Lena Solis',
      ageMark: '23',
      homeRegion: 'Austria',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_pine_light.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-studio-glance',
      publicName: 'Maren Lee',
      ageMark: '22',
      homeRegion: 'Korea',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_studio_glance.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-rooftop-note',
      publicName: 'Anya Reed',
      ageMark: '20',
      homeRegion: 'Portugal',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_rooftop_note.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-market-sun',
      publicName: 'Celia Grant',
      ageMark: '25',
      homeRegion: 'Belgium',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_market_sun.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-tennis-shade',
      publicName: 'Avery Lane',
      ageMark: '23',
      homeRegion: 'United States',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_tennis_shade.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-winter-bank',
      publicName: 'Noemi Hart',
      ageMark: '26',
      homeRegion: 'Norway',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_winter_bank.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'bloom-stair-light',
      publicName: 'Freya Stone',
      ageMark: '22',
      homeRegion: 'Iceland',
      signalBand: KeeperSignalBand.bloom,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_bloom_stair_light.jpg',
    ),
  ];

  static const museKeepers = [
    CapsuleKeeper(
      keeperId: 'muse-garden-path',
      publicName: 'Evan Hale',
      ageMark: '24',
      homeRegion: 'Canada',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_garden_path.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-warm-wall',
      publicName: 'Theo Mercer',
      ageMark: '22',
      homeRegion: 'United States',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_warm_wall.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-black-room',
      publicName: 'Milo Quinn',
      ageMark: '23',
      homeRegion: 'United Kingdom',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_black_room.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-highland-walk',
      publicName: 'Arlo Finch',
      ageMark: '26',
      homeRegion: 'New Zealand',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_highland_walk.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-pavement-smile',
      publicName: 'Jules Ward',
      ageMark: '25',
      homeRegion: 'France',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_pavement_smile.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-stone-courtyard',
      publicName: 'Luca Bennett',
      ageMark: '23',
      homeRegion: 'Italy',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_stone_courtyard.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-sea-rooftop',
      publicName: 'Kai Morgan',
      ageMark: '21',
      homeRegion: 'Australia',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_sea_rooftop.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-cafe-shadow',
      publicName: 'Nico Reyes',
      ageMark: '24',
      homeRegion: 'Spain',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_cafe_shadow.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-neutral-portrait',
      publicName: 'Oscar Venn',
      ageMark: '20',
      homeRegion: 'Ireland',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_neutral_portrait.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-bright-wall',
      publicName: 'Rory Ellis',
      ageMark: '22',
      homeRegion: 'Denmark',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_bright_wall.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-city-bench',
      publicName: 'Max Orlan',
      ageMark: '25',
      homeRegion: 'Germany',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_city_bench.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-dark-room',
      publicName: 'Dane Carter',
      ageMark: '24',
      homeRegion: 'Netherlands',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_dark_room.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-car-window',
      publicName: 'Caleb North',
      ageMark: '27',
      homeRegion: 'United States',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_car_window.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-balcony-light',
      publicName: 'Silas Brooks',
      ageMark: '23',
      homeRegion: 'Austria',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_balcony_light.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-ink-studio',
      publicName: 'Eli Porter',
      ageMark: '22',
      homeRegion: 'Belgium',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_ink_studio.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-rooftop-edge',
      publicName: 'Rowan Miles',
      ageMark: '21',
      homeRegion: 'Portugal',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_rooftop_edge.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-sunlit-selfie',
      publicName: 'Finn Hayes',
      ageMark: '23',
      homeRegion: 'Sweden',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_sunlit_selfie.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-marble-colonnade',
      publicName: 'Julian Cross',
      ageMark: '26',
      homeRegion: 'Greece',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_marble_colonnade.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-window-table',
      publicName: 'Noah Briar',
      ageMark: '24',
      homeRegion: 'Norway',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_window_table.jpg',
    ),
    CapsuleKeeper(
      keeperId: 'muse-travel-strap',
      publicName: 'Adam Vale',
      ageMark: '22',
      homeRegion: 'Switzerland',
      signalBand: KeeperSignalBand.muse,
      portraitAsset:
          'assets/morrowly_art/keepers/morrowly_keeper_muse_travel_strap.jpg',
    ),
  ];

  static const memorySnaps = [
    CapsuleMemoryFragment(
      fragmentId: 'memory-garden-portrait',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_garden_portrait.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Garden light',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-amber-room-table',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_amber_room_table.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Amber table',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-dusk-window-note',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_dusk_window_note.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Dusk window',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-palm-street-walk',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_palm_street_walk.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Palm street',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-lemonade-arcade',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_lemonade_arcade.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Lemonade stop',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-cathedral-morning',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_cathedral_morning.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Cathedral morning',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-quiet-stair-wait',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_quiet_stair_wait.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Quiet stair',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-poolside-wings',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_poolside_wings.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Poolside wings',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-car-window-drive',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_car_window_drive.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Window drive',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-paper-wall-pause',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_paper_wall_pause.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Paper wall',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-handheld-game-rest',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_handheld_game_rest.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Game rest',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-green-path-turn',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_green_path_turn.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Green path',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-coffee-letter-table',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_coffee_letter_table.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Coffee letter',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-harbor-supper-sunset',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_harbor_supper_sunset.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Harbor supper',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-resort-pool-still',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_resort_pool_still.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Pool still',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-cafe-companion-table',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_cafe_companion_table.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Cafe companion',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-flower-market-smile',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_flower_market_smile.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Flower market',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-lake-cocktail-view',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_lake_cocktail_view.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Lake table',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-hammock-valley-rest',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_hammock_valley_rest.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Valley rest',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-beach-mat-memory',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_beach_mat_memory.jpg',
      fragmentKind: MemoryFragmentKind.motion,
      captionTrace: 'Beach memory',
    ),
    CapsuleMemoryFragment(
      fragmentId: 'memory-travel-mirror-lane',
      sourcePath:
          'assets/morrowly_art/moments/morrowly_moment_travel_mirror_lane.jpg',
      fragmentKind: MemoryFragmentKind.still,
      captionTrace: 'Travel mirror',
    ),
  ];

  static List<CapsuleKeeper> get allKeepers => [
    ...bloomKeepers,
    ...museKeepers,
  ];

  static List<CapsuleOpeningPreset> openingPresets(DateTime anchor) {
    return [
      CapsuleOpeningPreset(
        presetId: 'one-month',
        label: 'One month',
        unlocksAt: DateTime(anchor.year, anchor.month + 1, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'three-months',
        label: 'Three months',
        unlocksAt: DateTime(anchor.year, anchor.month + 3, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'six-months',
        label: 'Six months',
        unlocksAt: DateTime(anchor.year, anchor.month + 6, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'one-year',
        label: 'One year',
        unlocksAt: DateTime(anchor.year + 1, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'three-years',
        label: 'Three years',
        unlocksAt: DateTime(anchor.year + 3, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'five-years',
        label: 'Five years',
        unlocksAt: DateTime(anchor.year + 5, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetId: 'ten-years',
        label: 'Ten years',
        unlocksAt: DateTime(anchor.year + 10, anchor.month, anchor.day, 10, 30),
      ),
    ];
  }

  static List<PublicCapsuleSeal> squareNotes() {
    final keepers = allKeepers;
    return [
      PublicCapsuleSeal(
        sealId: 'square-rain-romance',
        keeper: bloomKeepers[0],
        sealedMessage:
            'Sealing this lake light for a later morning, when I need proof that quiet days can still glow.',
        memoryFragments: [memorySnaps[13], memorySnaps[19]],
        sealedAt: DateTime(2025, 2, 25, 21, 10),
        unlocksAt: DateTime(2027, 6, 29, 10, 30),
        shelfScope: CapsuleShelfScope.publicSquare,
        visitorTrail: keepers,
        replyTrailCount: 156,
        replies: [
          CapsuleReply(
            replyId: 'rain-elara',
            author: bloomKeepers[1],
            sealedMessage:
                'This feels like a promise made at sunset. I hope future you recognizes the warmth right away.',
            arrivalLabel: '18 min ago',
          ),
          CapsuleReply(
            replyId: 'rain-kai',
            author: museKeepers[6],
            sealedMessage:
                'The beach table makes the memory feel unhurried. Save that softness.',
            arrivalLabel: '42 min ago',
          ),
          CapsuleReply(
            replyId: 'rain-talia',
            author: bloomKeepers[11],
            sealedMessage:
                'Leaving a wish here: may the future version of this day still know how to laugh.',
            arrivalLabel: '1h ago',
          ),
        ],
      ),
      PublicCapsuleSeal(
        sealId: 'square-window-return',
        keeper: museKeepers[7],
        sealedMessage:
            'Leaving a little evidence that this quiet season still had color.',
        memoryFragments: [memorySnaps[2], memorySnaps[8], memorySnaps[11]],
        sealedAt: DateTime(2025, 4, 16, 18, 40),
        unlocksAt: DateTime(2026, 6, 1, 9, 0),
        shelfScope: CapsuleShelfScope.publicSquare,
        visitorTrail: keepers.reversed.toList(),
        replyTrailCount: 92,
        replies: [
          CapsuleReply(
            replyId: 'window-rory',
            author: museKeepers[9],
            sealedMessage:
                'Quiet seasons count too. This one looks like it taught you how to breathe slower.',
            arrivalLabel: '7 min ago',
          ),
          CapsuleReply(
            replyId: 'window-maren',
            author: bloomKeepers[14],
            sealedMessage:
                'I like how ordinary this feels. Sometimes that is exactly the proof worth keeping.',
            arrivalLabel: '33 min ago',
          ),
          CapsuleReply(
            replyId: 'window-luca',
            author: museKeepers[5],
            sealedMessage:
                'When it opens, I hope the color comes back even brighter than you expected.',
            arrivalLabel: '2h ago',
          ),
        ],
      ),
      PublicCapsuleSeal(
        sealId: 'square-coffee-letter',
        keeper: bloomKeepers[12],
        sealedMessage:
            'If you are reading this, remember the table where the decision finally felt small enough.',
        memoryFragments: [memorySnaps[12], memorySnaps[15]],
        sealedAt: DateTime(2025, 8, 3, 16, 12),
        unlocksAt: DateTime(2026, 12, 26, 10, 30),
        shelfScope: CapsuleShelfScope.privateShelf,
        visitorTrail: keepers.sublist(4, 26),
        replyTrailCount: 47,
      ),
      PublicCapsuleSeal(
        sealId: 'square-harbor-promise',
        keeper: museKeepers[18],
        sealedMessage:
            'The evening was ordinary, which is why I want to keep it sealed.',
        memoryFragments: [memorySnaps[0], memorySnaps[1], memorySnaps[3]],
        sealedAt: DateTime(2025, 9, 12, 20, 5),
        unlocksAt: DateTime(2028, 1, 7, 11, 0),
        shelfScope: CapsuleShelfScope.publicSquare,
        visitorTrail: keepers.sublist(10),
        replyTrailCount: 118,
        replies: [
          CapsuleReply(
            replyId: 'harbor-noah',
            author: museKeepers[18],
            sealedMessage:
                'Ordinary evenings are usually the ones that become landmarks later.',
            arrivalLabel: '12 min ago',
          ),
          CapsuleReply(
            replyId: 'harbor-rhea',
            author: bloomKeepers[12],
            sealedMessage:
                'This sounds like the kind of promise that grows quietly in the background.',
            arrivalLabel: '59 min ago',
          ),
          CapsuleReply(
            replyId: 'harbor-adam',
            author: museKeepers[19],
            sealedMessage:
                'Leaving a marker here for the future: remember who made simple feel enough.',
            arrivalLabel: '3h ago',
          ),
        ],
      ),
      PublicCapsuleSeal(
        sealId: 'square-arcade-morning',
        keeper: bloomKeepers[4],
        sealedMessage:
            'A tiny note for the version of me who forgot how bright this day felt.',
        memoryFragments: [
          memorySnaps[4],
          memorySnaps[5],
          memorySnaps[6],
          memorySnaps[7],
        ],
        sealedAt: DateTime(2026, 1, 18, 12, 4),
        unlocksAt: DateTime(2026, 6, 29, 9, 30),
        shelfScope: CapsuleShelfScope.privateShelf,
        visitorTrail: keepers.sublist(0, 18),
        replyTrailCount: 63,
      ),
      PublicCapsuleSeal(
        sealId: 'square-valley-afterlight',
        keeper: museKeepers[16],
        sealedMessage:
            'When the year gets crowded again, open this and borrow the quiet.',
        memoryFragments: [
          memorySnaps[9],
          memorySnaps[10],
          memorySnaps[16],
          memorySnaps[17],
          memorySnaps[18],
          memorySnaps[20],
        ],
        sealedAt: DateTime(2026, 2, 11, 15, 30),
        unlocksAt: DateTime(2031, 6, 29, 10, 30),
        shelfScope: CapsuleShelfScope.publicSquare,
        visitorTrail: keepers,
        replyTrailCount: 201,
        replies: [
          CapsuleReply(
            replyId: 'valley-finn',
            author: museKeepers[16],
            sealedMessage:
                'Borrowing quiet from a better day is a gentle way to carry a crowded year.',
            arrivalLabel: '24 min ago',
          ),
          CapsuleReply(
            replyId: 'valley-sofia',
            author: bloomKeepers[5],
            sealedMessage:
                'This capsule feels like shade after a long walk. I hope it still cools the future.',
            arrivalLabel: '1h ago',
          ),
          CapsuleReply(
            replyId: 'valley-jules',
            author: museKeepers[4],
            sealedMessage:
                'Five years is far away, but this kind of calm usually knows how to wait.',
            arrivalLabel: '4h ago',
          ),
        ],
      ),
    ];
  }
}
