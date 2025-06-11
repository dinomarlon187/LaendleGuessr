abstract class Account{
  final int uid;
    final String username;
    final String password;
    final bool isAdmin;

    Account({
      required this.uid,
      required this.username,
      required this.password,
      required this.isAdmin,
    });
}