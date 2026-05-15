enum PlayerAvailability { present, absent }

extension PlayerAvailabilityLabel on PlayerAvailability {
  String get label {
    switch (this) {
      case PlayerAvailability.present:
        return "Present";
      case PlayerAvailability.absent:
        return "Absent";
    }
  }
}
