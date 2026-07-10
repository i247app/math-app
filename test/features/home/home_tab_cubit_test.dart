import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/home/home_tab_cubit.dart';

void main() {
  group('HomeTabCubit characterization', () {
    test('tracks tab selection history and revision', () async {
      final cubit = _TestHomeTabCubit();

      cubit.selectTab(3);

      expect(cubit.state.activeTab, 3);
      expect(cubit.state.previousTab, 0);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });

    test('ignores selections outside the configured tab range', () async {
      final cubit = _TestHomeTabCubit();

      cubit.selectTab(-1);
      cubit.selectTab(5);

      expect(cubit.state.activeTab, 0);
      expect(cubit.state.selectionRevision, 0);
      await cubit.close();
    });

    test('records a same-tab reentry as a new selection', () async {
      final cubit = _TestHomeTabCubit();

      cubit.selectTab(0);

      expect(cubit.state.activeTab, 0);
      expect(cubit.state.previousTab, 0);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });
  });
}

class _TestHomeTabCubit extends HomeTabCubit {
  _TestHomeTabCubit() : super(maxTabIndex: 4);
}
