enum StudentAvatar {
  girl1('assets/images/girl_1.avif'),
  girl2('assets/images/girl_2.avif'),
  girl3('assets/images/girl_3.avif'),
  boy1('assets/images/boy_1.avif'),
  boy2('assets/images/boy_2.avif'),
  boy3('assets/images/boy_3.avif');

  const StudentAvatar(this.asset);

  final String asset;

  static StudentAvatar fromName(String? name) {
    switch (name) {
      case 'girl':
        return StudentAvatar.girl1;
      case 'boy':
        return StudentAvatar.boy1;
      default:
        return StudentAvatar.values.firstWhere(
          (avatar) => avatar.name == name,
          orElse: () => StudentAvatar.girl1,
        );
    }
  }
}
