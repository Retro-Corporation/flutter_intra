enum FrequencyUnit { daily, weekly, monthly }

extension FrequencyUnitLabel on FrequencyUnit {
  String get label => switch (this) {
        FrequencyUnit.daily => 'Daily',
        FrequencyUnit.weekly => 'Weekly',
        FrequencyUnit.monthly => 'Monthly',
      };
}
