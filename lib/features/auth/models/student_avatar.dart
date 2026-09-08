enum StudentAvatar {
  girl('👩🏻‍🎓'),
  boy('👨🏻‍🎓');

  const StudentAvatar(this.glyph);

  final String glyph;

  static StudentAvatar fromName(String? name) {
    return StudentAvatar.values.firstWhere(
      (avatar) => avatar.name == name,
      orElse: () => StudentAvatar.girl,
    );
  }
}
