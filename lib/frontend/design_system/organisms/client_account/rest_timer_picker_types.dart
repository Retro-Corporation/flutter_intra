enum DurationUnit { seconds, min }

extension DurationUnitLabel on DurationUnit {
  String get label => switch (this) {
        DurationUnit.seconds => 'Seconds',
        DurationUnit.min => 'Min',
      };
}
