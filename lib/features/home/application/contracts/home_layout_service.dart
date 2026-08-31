import 'package:numi/features/home/domain/models/home_layout.dart';

abstract interface class HomeLayoutService {
  Future<HomeLayout> getLayout({required int profileId});
}
