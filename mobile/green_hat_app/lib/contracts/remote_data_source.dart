import '../models/account.dart';
import '../models/mentor.dart';

abstract class RemoteDataDource {
  Future<List<Mentor>> getMentors(
      {String query = '', String category = 'Todos'});

  Future<Mentor> getMentor(String id);

  Future<void> requestMentor(
      {required String mentorId,
      required String type,
      required String message,
      required bool shareReport,
      Map<String, dynamic>? report});

  Future<Account> signUp({
    required String name,
    required String email,
    required String password,
    required String businessSector,
  });

  Future<Account> logIn({
    required String email,
    required String password,
  });

  Future<Account> saveProjectStage(String projectStage);

  Future<Account?> restoreSession();

  Future<void> logOut();

  void dispose();
}
