enum SkillLevel {
  newbie,
  beginner,
  upperBeginner,
  lowerIntermediate,
  intermediate,
  upperIntermediate,
  advanced,
  expert,
}

extension SkillLevelLabel on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.newbie:
        return "Newbie";
      case SkillLevel.beginner:
        return "Beginner";
      case SkillLevel.upperBeginner:
        return "Upper Beginner";
      case SkillLevel.lowerIntermediate:
        return "Lower Intermediate";
      case SkillLevel.intermediate:
        return "Intermediate";
      case SkillLevel.upperIntermediate:
        return "Upper Intermediate";
      case SkillLevel.advanced:
        return "Advanced";
      case SkillLevel.expert:
        return "Expert";
    }
  }
}
