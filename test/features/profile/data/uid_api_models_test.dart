import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/home/data/home_layout_api_models.dart';
import 'package:numi/features/profile/data/grade_api_models.dart';
import 'package:numi/features/profile/data/profile_api_models.dart';
import 'package:numi/features/profile/data/program_api_models.dart';
import 'package:numi/features/profile/data/semester_api_models.dart';

void main() {
  test('profile and lookup requests serialize uid', () {
    expect(const ProfileListRequest(userId: 21).toJson(), {'uid': 21});
    expect(const ProfileListRequest(search: 'An').toJson(), {'search': 'An'});
    expect(
      const CreateProfileRequest(
        userId: 21,
        schoolId: 3,
        name: 'An',
      ).toJson()['uid'],
      21,
    );
    expect(const ProgramListRequest(userId: 21).toJson(), {'uid': 21});
    expect(const SemesterListRequest(userId: 21).toJson(), {'uid': 21});
    expect(const GradeListRequest(userId: 21).toJson(), {'uid': 21});
  });

  test('profile responses read uid from nested profile objects', () {
    final list = ProfileListResponse.fromJson(<String, dynamic>{
      'mstatus': 200,
      'profiles': <Map<String, dynamic>>[
        {'uid': 21},
      ],
    });
    expect(list.profiles.single.userId, 21);

    final created = CreateProfileResponse.fromJson(<String, dynamic>{
      'mstatus': 200,
      'profile': <String, dynamic>{'uid': 21},
    });
    final updated = UpdateProfileResponse.fromJson(<String, dynamic>{
      'mstatus': 200,
      'profile': <String, dynamic>{'uid': 21},
    });
    expect(created.profile?.userId, 21);
    expect(updated.profile?.userId, 21);
  });

  test('home layout reads uid in nested profile locations', () {
    final response = HomeLayoutResponseDto.fromJson(<String, dynamic>{
      'mstatus': 200,
      'home': <String, dynamic>{
        'profile': <String, dynamic>{'uid': 21},
        'sub_profiles': <Map<String, dynamic>>[
          {'uid': 22},
        ],
        'parent': <String, dynamic>{
          'children': <Map<String, dynamic>>[
            {'uid': 23},
          ],
        },
        'tasks': <Map<String, dynamic>>[
          {
            'child': <String, dynamic>{'uid': 24},
          },
        ],
        'messages': <Map<String, dynamic>>[
          {
            'sender': <String, dynamic>{'uid': 25},
          },
        ],
      },
    });

    expect(response.home?.profile?.userId, 21);
    expect(response.home?.subProfiles.single.userId, 22);
    expect(response.home?.parent?.children.single.userId, 23);
    expect(response.home?.tasks.single.child?.userId, 24);
    expect(response.home?.messages.single.sender?.userId, 25);
  });
}
