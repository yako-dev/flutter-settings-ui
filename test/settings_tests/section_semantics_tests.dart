import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Each row of a section is a semantics node of its own, in every style.
/// On Android, a section whose only tappable row sat among other rows was
/// one node: screen readers read "Plain, Value, Disabled, Active" as one
/// button.

const _styles = [
  DevicePlatform.iOS,
  DevicePlatform.android,
  DevicePlatform.web,
  DevicePlatform.macOS,
  DevicePlatform.windows,
  DevicePlatform.linux,
];

/// Which rows of the section do something.
enum _Tappable {
  none('no row is tappable'),
  one('one row of several is tappable'),
  all('every row is tappable'),
  onlyASwitch('only a switch row does something');

  const _Tappable(this.description);

  final String description;
}

/// The semantics nodes with a label that a screen reader visits, in the
/// order it reads them.
List<SemanticsNode> _nodesInReadingOrder(WidgetTester tester) {
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent && node.getSemanticsData().label.isNotEmpty) {
      nodes.add(node);
    }
    for (final child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return nodes;
}

/// What a screen reader gets for the row whose title is [title].
SemanticsData _rowOf(WidgetTester tester, String title) => tester
    .getSemantics(
      find.descendant(
        of: find.byKey(const ValueKey('settings_split_list_pane')),
        matching: find.text(title),
      ),
    )
    .getSemanticsData();

void sectionSemanticsTests() {
  group('Each row of a section is its own semantics node', () {
    for (final platform in _styles) {
      for (final tappable in _Tappable.values) {
        testWidgets('$platform: ${tappable.description}', (tester) async {
          final handle = tester.ensureSemantics();
          final log = <String>[];
          final all = tappable == _Tappable.all;
          void Function(BuildContext)? press(String title, bool on) =>
              on ? (_) => log.add(title) : null;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SettingsList(
                  platform: platform,
                  sections: [
                    SettingsSection(
                      title: const Text('Head'),
                      tiles: [
                        SettingsTile(
                          title: const Text('Plain'),
                          value: const Text('Value'),
                          onPressed: press('Plain', all),
                        ),
                        CustomSettingsTile(child: const Text('Custom')),
                        SettingsTile(
                          title: const Text('Disabled'),
                          enabled: false,
                          onPressed: press('Disabled', all),
                        ),
                        SettingsTile.navigation(
                          title: const Text('Active'),
                          onPressed: press(
                            'Active',
                            all || tappable == _Tappable.one,
                          ),
                        ),
                        if (tappable == _Tappable.onlyASwitch)
                          SettingsTile.switchTile(
                            title: const Text('Wi-Fi'),
                            initialValue: true,
                            onToggle: (value) => log.add('Wi-Fi $value'),
                          ),
                        SettingsTile(
                          title: const Text('Last'),
                          description: const Text('Footer'),
                          onPressed: press('Last', all),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );

          final rows = [
            'Plain',
            'Custom',
            'Disabled',
            'Active',
            if (tappable == _Tappable.onlyASwitch) 'Wi-Fi',
            'Last',
          ];
          final nodes = _nodesInReadingOrder(tester);
          final labels = [
            for (final node in nodes) node.getSemanticsData().label,
          ];
          int indexOf(String text) =>
              labels.indexWhere((label) => label.contains(text));

          // Each title is read once, with no other title in its node.
          for (final label in labels) {
            expect(
              ['Head', ...rows].where(label.contains),
              hasLength(lessThanOrEqualTo(1)),
              reason: '"$label" holds several rows',
            );
          }
          for (final text in ['Head', ...rows, 'Footer']) {
            expect(
              labels.where((label) => label.contains(text)),
              hasLength(1),
              reason: '"$text" in $labels',
            );
          }
          // In the order they are drawn: the section title first, and the
          // description with its row or right after it.
          final order = [
            for (final text in ['Head', ...rows, 'Footer']) indexOf(text),
          ];
          expect(order, [...order]..sort(), reason: '$labels');
          expect(labels[indexOf('Plain')], contains('Value'));
          expect(indexOf('Footer') - indexOf('Last'), lessThanOrEqualTo(1));

          final head = nodes[indexOf('Head')].getSemanticsData();
          expect(head.label, 'Head');
          expect(head.flagsCollection.isHeader, isTrue);

          for (final title in rows) {
            final node = nodes[indexOf(title)];
            final data = node.getSemanticsData();
            final flags = data.flagsCollection;
            final hasOnPressed =
                (all && title != 'Custom' && title != 'Wi-Fi') ||
                (tappable == _Tappable.one && title == 'Active');
            final canTap =
                (hasOnPressed && title != 'Disabled') || title == 'Wi-Fi';
            expect(flags.isButton, hasOnPressed, reason: '$title: button');
            expect(
              data.hasAction(SemanticsAction.tap),
              canTap,
              reason: '$title: tap action',
            );
            if (hasOnPressed) {
              // An enabled button, or a dimmed one.
              expect(
                flags.isEnabled,
                title == 'Disabled' ? Tristate.isFalse : Tristate.isTrue,
                reason: '$title: enabled state',
              );
            }
            if (title == 'Wi-Fi') {
              expect(data.label, 'Wi-Fi');
              expect(flags.isToggled, Tristate.isTrue);
            }
            if (canTap) {
              node.owner!.performAction(node.id, SemanticsAction.tap);
              await tester.pumpAndSettle();
            }
          }
          expect(log, [
            if (all) ...['Plain', 'Active', 'Last'],
            if (tappable == _Tappable.one) 'Active',
            if (tappable == _Tappable.onlyASwitch) 'Wi-Fi false',
          ]);
          handle.dispose();
        });
      }
    }
  });

  group('Each row of a split view list pane is its own semantics node', () {
    for (final platform in _styles) {
      testWidgets('$platform', (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsSplitView(
              platform: platform,
              sections: [
                SettingsSection(
                  title: const Text('Head'),
                  tiles: [
                    SettingsTile(title: const Text('Plain')),
                    SettingsTile(title: const Text('Disabled'), enabled: false),
                    SettingsTile.navigation(
                      title: const Text('Network'),
                      destination: SettingsDestination(
                        id: 'network',
                        builder: (_) => const Text('Network page'),
                      ),
                    ),
                    SettingsTile(title: const Text('Last')),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final head = _rowOf(tester, 'Head');
        expect(head.label, 'Head');
        expect(head.flagsCollection.isHeader, isTrue);
        for (final title in ['Plain', 'Disabled', 'Last']) {
          final row = _rowOf(tester, title);
          expect(row.label, title);
          expect(row.flagsCollection.isButton, isFalse, reason: title);
          expect(row.hasAction(SemanticsAction.tap), isFalse, reason: title);
        }
        // The selected row says so on its own node, not its section's.
        final network = _rowOf(tester, 'Network');
        expect(network.label, 'Network');
        expect(network.flagsCollection.isButton, isTrue);
        expect(network.hasAction(SemanticsAction.tap), isTrue);
        expect(network.flagsCollection.isSelected, Tristate.isTrue);
        expect(
          tester
              .getSemantics(
                find.descendant(
                  of: find.byKey(const ValueKey('settings_split_list_pane')),
                  matching: find.text('Network'),
                ),
              )
              .parent!
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          isNot(Tristate.isTrue),
        );
        handle.dispose();
      });
    }
  });
}
