import 'package:numi/features/home/data/dto/home_layout_models.dart';

abstract interface class HomeLayoutService {
  Future<HomeLayout> getLayout({required int profileId});
}
