abstract class Account{
  final int uid;
  final String username;
  final bool isAdmin;

  Account({
    required this.uid,
    required this.username,
    required this.isAdmin,
  });
}