import 'package:flutter/material.dart';

/// Reconciles keyed cards without replaying entrances for unchanged exams.
class AnimatedHomeAssessmentItems extends StatefulWidget {
  const AnimatedHomeAssessmentItems({super.key, required this.items});
  final List<Widget> items;

  @override
  State<AnimatedHomeAssessmentItems> createState() =>
      _AnimatedHomeAssessmentItemsState();
}

class _AnimatedHomeAssessmentItemsState
    extends State<AnimatedHomeAssessmentItems> {
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<Widget> _items = [...widget.items];

  Duration get _duration => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 520);

  @override
  void didUpdateWidget(covariant AnimatedHomeAssessmentItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    final desired = widget.items;
    for (var index = _items.length - 1; index >= 0; index--) {
      if (!desired.any((item) => item.key == _items[index].key)) _remove(index);
    }
    for (var index = 0; index < desired.length; index++) {
      final item = desired[index];
      if (index < _items.length && _items[index].key == item.key) {
        _items[index] = item;
        continue;
      }
      final oldIndex = _items.indexWhere((old) => old.key == item.key);
      if (oldIndex >= 0) _remove(oldIndex);
      _items.insert(index, item);
      _listKey.currentState?.insertItem(index, duration: _duration);
    }
  }

  void _remove(int index) {
    final item = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          IgnorePointer(child: _transition(item, animation)),
      duration: _duration,
    );
  }

  Widget _transition(Widget child, Animation<double> animation) =>
      SizeTransition(
        sizeFactor: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: ScaleTransition(
            scale: animation.drive(
              Tween(
                begin: 0.94,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOutBack)),
            ),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedList(
    key: _listKey,
    initialItemCount: _items.length,
    shrinkWrap: true,
    primary: false,
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index, animation) =>
        _transition(_items[index], animation),
  );
}
