import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';

abstract final class CapsuleArtwork {
  static const threadUnderline = 'assets/images/Thread.png';
  static const actionOrbit = 'assets/images/Orbit.png';
  static const actionFeather = 'assets/images/Nova.png';
  static const capsuleCoin = 'assets/images/Capsule.png';
  static const heroJar = 'assets/images/Dream.png';
  static const previewWash = 'assets/images/Recall.png';
  static const sealedPostcard = 'assets/images/Postcard.png';
  static const dialogPrelude = 'assets/images/Prelude.png';
  static const capsuleTypeLetter = 'assets/images/Glimpse.png';
  static const capsuleTypeVideo = 'assets/images/Reminisce.png';
  static const customTimeGlyph = 'assets/images/Memento.png';
  static const bloomMark = 'assets/images/Bloom.png';
  static const museMark = 'assets/images/Muse.png';
  static const sayButton = 'assets/images/Spark.png';
  static const myCapsulesSmall = 'assets/images/Reunion.png';
  static const viewCapsules = 'assets/images/Locket.png';
  static const confirmSeal = 'assets/images/Heartbeat.png';
  static const sealedCapsules = 'assets/images/Yesterday.png';
  static const confirmButton = 'assets/images/Duskfall.png';
  static const backHome = 'assets/images/Presence.png';
  static const publicChip = 'assets/images/Evermore.png';
  static const privateChip = 'assets/images/Anchor.png';
  static const checkChip = 'assets/images/Gather.png';
  static const deleteChip = 'assets/images/Bond.png';
}

abstract final class CapsuleSquareSeed {
  static const currentKeeper = CapsuleKeeper(
    keeperKey: 'self-rainlit-room',
    displayName: 'Mira Vale',
    ageLine: '24',
    placeLine: 'United States',
    signalBand: KeeperSignalBand.bloom,
    avatarAsset: 'assets/images/head/bloom_arch_window.jpg',
  );

  static const bloomKeepers = [
    CapsuleKeeper(
      keeperKey: 'bloom-arch-window',
      displayName: 'Carolyn Massey',
      ageLine: '23',
      placeLine: 'Australia',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_arch_window.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-cedar-terrace',
      displayName: 'Elara Finch',
      ageLine: '22',
      placeLine: 'Canada',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_cedar_terrace.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-sunlit-step',
      displayName: 'Nora Wells',
      ageLine: '25',
      placeLine: 'Ireland',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_sunlit_step.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-hill-path',
      displayName: 'Livia Rowe',
      ageLine: '21',
      placeLine: 'New Zealand',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_hill_path.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-morning-arch',
      displayName: 'Arielle Knox',
      ageLine: '24',
      placeLine: 'France',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_morning_arch.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-campus-courtyard',
      displayName: 'Sofia Marin',
      ageLine: '20',
      placeLine: 'Spain',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_campus_courtyard.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-evening-room',
      displayName: 'Maya Sterling',
      ageLine: '26',
      placeLine: 'United States',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_evening_room.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-cafe-awning',
      displayName: 'Kira Ashby',
      ageLine: '23',
      placeLine: 'Italy',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_cafe_awning.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-soft-corner',
      displayName: 'Ivy Monroe',
      ageLine: '22',
      placeLine: 'Netherlands',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_soft_corner.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-gold-room',
      displayName: 'June Calder',
      ageLine: '24',
      placeLine: 'United Kingdom',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_gold_room.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-clear-window',
      displayName: 'Sienna Vale',
      ageLine: '25',
      placeLine: 'Sweden',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_clear_window.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-lake-glow',
      displayName: 'Talia Arden',
      ageLine: '21',
      placeLine: 'Switzerland',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_lake_glow.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-blonde-lane',
      displayName: 'Rhea Collins',
      ageLine: '24',
      placeLine: 'Denmark',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_blonde_lane.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-pine-light',
      displayName: 'Lena Solis',
      ageLine: '23',
      placeLine: 'Austria',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_pine_light.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-studio-glance',
      displayName: 'Maren Lee',
      ageLine: '22',
      placeLine: 'Korea',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_studio_glance.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-rooftop-note',
      displayName: 'Anya Reed',
      ageLine: '20',
      placeLine: 'Portugal',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_rooftop_note.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-market-sun',
      displayName: 'Celia Grant',
      ageLine: '25',
      placeLine: 'Belgium',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_market_sun.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-tennis-shade',
      displayName: 'Avery Lane',
      ageLine: '23',
      placeLine: 'United States',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_tennis_shade.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-winter-bank',
      displayName: 'Noemi Hart',
      ageLine: '26',
      placeLine: 'Norway',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_winter_bank.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'bloom-stair-light',
      displayName: 'Freya Stone',
      ageLine: '22',
      placeLine: 'Iceland',
      signalBand: KeeperSignalBand.bloom,
      avatarAsset: 'assets/images/head/bloom_stair_light.jpg',
    ),
  ];

  static const museKeepers = [
    CapsuleKeeper(
      keeperKey: 'muse-garden-path',
      displayName: 'Evan Hale',
      ageLine: '24',
      placeLine: 'Canada',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_garden_path.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-warm-wall',
      displayName: 'Theo Mercer',
      ageLine: '22',
      placeLine: 'United States',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_warm_wall.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-black-room',
      displayName: 'Milo Quinn',
      ageLine: '23',
      placeLine: 'United Kingdom',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_black_room.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-highland-walk',
      displayName: 'Arlo Finch',
      ageLine: '26',
      placeLine: 'New Zealand',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_highland_walk.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-pavement-smile',
      displayName: 'Jules Ward',
      ageLine: '25',
      placeLine: 'France',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_pavement_smile.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-stone-courtyard',
      displayName: 'Luca Bennett',
      ageLine: '23',
      placeLine: 'Italy',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_stone_courtyard.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-sea-rooftop',
      displayName: 'Kai Morgan',
      ageLine: '21',
      placeLine: 'Australia',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_sea_rooftop.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-cafe-shadow',
      displayName: 'Nico Reyes',
      ageLine: '24',
      placeLine: 'Spain',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_cafe_shadow.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-neutral-portrait',
      displayName: 'Oscar Venn',
      ageLine: '20',
      placeLine: 'Ireland',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_neutral_portrait.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-bright-wall',
      displayName: 'Rory Ellis',
      ageLine: '22',
      placeLine: 'Denmark',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_bright_wall.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-city-bench',
      displayName: 'Max Orlan',
      ageLine: '25',
      placeLine: 'Germany',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_city_bench.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-dark-room',
      displayName: 'Dane Carter',
      ageLine: '24',
      placeLine: 'Netherlands',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_dark_room.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-car-window',
      displayName: 'Caleb North',
      ageLine: '27',
      placeLine: 'United States',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_car_window.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-balcony-light',
      displayName: 'Silas Brooks',
      ageLine: '23',
      placeLine: 'Austria',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_balcony_light.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-ink-studio',
      displayName: 'Eli Porter',
      ageLine: '22',
      placeLine: 'Belgium',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_ink_studio.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-rooftop-edge',
      displayName: 'Rowan Miles',
      ageLine: '21',
      placeLine: 'Portugal',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_rooftop_edge.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-sunlit-selfie',
      displayName: 'Finn Hayes',
      ageLine: '23',
      placeLine: 'Sweden',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_sunlit_selfie.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-marble-colonnade',
      displayName: 'Julian Cross',
      ageLine: '26',
      placeLine: 'Greece',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_marble_colonnade.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-window-table',
      displayName: 'Noah Briar',
      ageLine: '24',
      placeLine: 'Norway',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_window_table.jpg',
    ),
    CapsuleKeeper(
      keeperKey: 'muse-travel-strap',
      displayName: 'Adam Vale',
      ageLine: '22',
      placeLine: 'Switzerland',
      signalBand: KeeperSignalBand.muse,
      avatarAsset: 'assets/images/head/muse_travel_strap.jpg',
    ),
  ];

  static const memorySnaps = [
    CapsuleMediaSnap(
      snapKey: 'memory-garden-portrait',
      assetPath: 'assets/images/post/memory_garden_portrait.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Garden light',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-amber-room-table',
      assetPath: 'assets/images/post/memory_amber_room_table.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Amber table',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-dusk-window-note',
      assetPath: 'assets/images/post/memory_dusk_window_note.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Dusk window',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-palm-street-walk',
      assetPath: 'assets/images/post/memory_palm_street_walk.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Palm street',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-lemonade-arcade',
      assetPath: 'assets/images/post/memory_lemonade_arcade.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Lemonade stop',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-cathedral-morning',
      assetPath: 'assets/images/post/memory_cathedral_morning.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Cathedral morning',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-quiet-stair-wait',
      assetPath: 'assets/images/post/memory_quiet_stair_wait.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Quiet stair',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-poolside-wings',
      assetPath: 'assets/images/post/memory_poolside_wings.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Poolside wings',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-car-window-drive',
      assetPath: 'assets/images/post/memory_car_window_drive.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Window drive',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-paper-wall-pause',
      assetPath: 'assets/images/post/memory_paper_wall_pause.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Paper wall',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-handheld-game-rest',
      assetPath: 'assets/images/post/memory_handheld_game_rest.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Game rest',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-green-path-turn',
      assetPath: 'assets/images/post/memory_green_path_turn.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Green path',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-coffee-letter-table',
      assetPath: 'assets/images/post/memory_coffee_letter_table.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Coffee letter',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-harbor-supper-sunset',
      assetPath: 'assets/images/post/memory_harbor_supper_sunset.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Harbor supper',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-resort-pool-still',
      assetPath: 'assets/images/post/memory_resort_pool_still.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Pool still',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-cafe-companion-table',
      assetPath: 'assets/images/post/memory_cafe_companion_table.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Cafe companion',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-flower-market-smile',
      assetPath: 'assets/images/post/memory_flower_market_smile.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Flower market',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-lake-cocktail-view',
      assetPath: 'assets/images/post/memory_lake_cocktail_view.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Lake table',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-hammock-valley-rest',
      assetPath: 'assets/images/post/memory_hammock_valley_rest.jpg',
      kind: CapsuleMediaKind.still,
      captionTrace: 'Valley rest',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-beach-mat-memory',
      assetPath: 'assets/images/post/memory_beach_mat_memory.jpg',
      kind: CapsuleMediaKind.motion,
      captionTrace: 'Beach memory',
    ),
    CapsuleMediaSnap(
      snapKey: 'memory-travel-mirror-lane',
      assetPath: 'assets/images/post/memory_travel_mirror_lane.jpg',
      kind: CapsuleMediaKind.still,
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
        presetKey: 'one-month',
        label: 'One month',
        openingAt: DateTime(anchor.year, anchor.month + 1, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'three-months',
        label: 'Three months',
        openingAt: DateTime(anchor.year, anchor.month + 3, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'six-months',
        label: 'Six months',
        openingAt: DateTime(anchor.year, anchor.month + 6, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'one-year',
        label: 'One year',
        openingAt: DateTime(anchor.year + 1, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'three-years',
        label: 'Three years',
        openingAt: DateTime(anchor.year + 3, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'five-years',
        label: 'Five years',
        openingAt: DateTime(anchor.year + 5, anchor.month, anchor.day, 10, 30),
      ),
      CapsuleOpeningPreset(
        presetKey: 'ten-years',
        label: 'Ten years',
        openingAt: DateTime(anchor.year + 10, anchor.month, anchor.day, 10, 30),
      ),
    ];
  }

  static List<CapsuleSquareNote> squareNotes() {
    final keepers = allKeepers;
    return [
      CapsuleSquareNote(
        noteKey: 'square-rain-romance',
        keeper: bloomKeepers[0],
        messageLine:
            'I hope scattered life can also have passionate romance. You must be happy in the future!',
        mediaSnaps: [memorySnaps[13], memorySnaps[19]],
        sealedAt: DateTime(2025, 2, 25, 21, 10),
        openingAt: DateTime(2027, 6, 29, 10, 30),
        visibility: CapsuleVisibility.publicSquare,
        visitorTrail: keepers,
        leftMessageCount: 156,
      ),
      CapsuleSquareNote(
        noteKey: 'square-window-return',
        keeper: museKeepers[7],
        messageLine:
            'Leaving a little evidence that this quiet season still had color.',
        mediaSnaps: [memorySnaps[2], memorySnaps[8], memorySnaps[11]],
        sealedAt: DateTime(2025, 4, 16, 18, 40),
        openingAt: DateTime(2026, 6, 1, 9, 0),
        visibility: CapsuleVisibility.publicSquare,
        visitorTrail: keepers.reversed.toList(),
        leftMessageCount: 92,
      ),
      CapsuleSquareNote(
        noteKey: 'square-coffee-letter',
        keeper: bloomKeepers[12],
        messageLine:
            'If you are reading this, remember the table where the decision finally felt small enough.',
        mediaSnaps: [memorySnaps[12], memorySnaps[15]],
        sealedAt: DateTime(2025, 8, 3, 16, 12),
        openingAt: DateTime(2026, 12, 26, 10, 30),
        visibility: CapsuleVisibility.privateShelf,
        visitorTrail: keepers.sublist(4, 26),
        leftMessageCount: 47,
      ),
      CapsuleSquareNote(
        noteKey: 'square-harbor-promise',
        keeper: museKeepers[18],
        messageLine:
            'The evening was ordinary, which is why I want to keep it sealed.',
        mediaSnaps: [memorySnaps[0], memorySnaps[1], memorySnaps[3]],
        sealedAt: DateTime(2025, 9, 12, 20, 5),
        openingAt: DateTime(2028, 1, 7, 11, 0),
        visibility: CapsuleVisibility.publicSquare,
        visitorTrail: keepers.sublist(10),
        leftMessageCount: 118,
      ),
      CapsuleSquareNote(
        noteKey: 'square-arcade-morning',
        keeper: bloomKeepers[4],
        messageLine:
            'A tiny note for the version of me who forgot how bright this day felt.',
        mediaSnaps: [
          memorySnaps[4],
          memorySnaps[5],
          memorySnaps[6],
          memorySnaps[7],
        ],
        sealedAt: DateTime(2026, 1, 18, 12, 4),
        openingAt: DateTime(2026, 6, 29, 9, 30),
        visibility: CapsuleVisibility.privateShelf,
        visitorTrail: keepers.sublist(0, 18),
        leftMessageCount: 63,
      ),
      CapsuleSquareNote(
        noteKey: 'square-valley-afterlight',
        keeper: museKeepers[16],
        messageLine:
            'When the year gets loud again, open this and borrow the quiet.',
        mediaSnaps: [
          memorySnaps[9],
          memorySnaps[10],
          memorySnaps[16],
          memorySnaps[17],
          memorySnaps[18],
          memorySnaps[20],
        ],
        sealedAt: DateTime(2026, 2, 11, 15, 30),
        openingAt: DateTime(2031, 6, 29, 10, 30),
        visibility: CapsuleVisibility.publicSquare,
        visitorTrail: keepers,
        leftMessageCount: 201,
      ),
    ];
  }
}
