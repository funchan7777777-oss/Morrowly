enum FocusWeightBand { lightTouch, steadyBlock, deepHarbor }

extension FocusWeightBandCopy on FocusWeightBand {
  String get label {
    return switch (this) {
      FocusWeightBand.lightTouch => 'Light touch',
      FocusWeightBand.steadyBlock => 'Steady block',
      FocusWeightBand.deepHarbor => 'Deep harbor',
    };
  }
}
