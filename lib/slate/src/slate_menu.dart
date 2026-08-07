import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_theme.dart';

/// Gives the rows inside a menu a way to close the menu they are in, and every
/// menu above it.
///
/// The rows are plain widgets rather than `MenuItemButton`s, so that they can
/// be drawn exactly as designed; the trade is that closing becomes their own
/// responsibility. The scope is installed *above* the [MenuAnchor] rather than
/// inside its builder, because the panel is an overlay child and only inherits
/// from the anchor's ancestors.
class SlateMenuScope extends InheritedWidget {
  const SlateMenuScope({
    required this.controller,
    required this.parent,
    required super.child,
    super.key,
  });

  final MenuController controller;

  /// The menu this one opened from, or null for a top-level menu.
  final SlateMenuScope? parent;

  /// Dismisses this menu and the whole chain it hangs off. Choosing a command
  /// in a submenu should put the interface away, not leave its parent standing.
  void closeAll() {
    controller.close();
    parent?.closeAll();
  }

  static SlateMenuScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SlateMenuScope>();

  @override
  bool updateShouldNotify(SlateMenuScope oldWidget) =>
      controller != oldWidget.controller || parent != oldWidget.parent;
}

/// Strips Material's surface off a menu so the kit can draw its own.
MenuStyle slateMenuStyle(SlateThemeData theme) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll<Color>(theme.palette.popover),
    surfaceTintColor: const WidgetStatePropertyAll<Color>(Color(0x00000000)),
    shadowColor: WidgetStatePropertyAll<Color>(theme.palette.shadow),
    elevation: const WidgetStatePropertyAll<double>(8),
    padding: WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(vertical: theme.metrics.radius),
    ),
    shape: WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.metrics.popoverRadius),
        side: BorderSide(color: theme.palette.border),
      ),
    ),
    visualDensity: VisualDensity.compact,
  );
}

/// A row of top-level menus that behave as one bar.
///
/// Without the shared state, each menu would be an island: opening File and
/// then sliding onto Edit would do nothing until you clicked again. Every menu
/// bar on every desktop follows the pointer once one of them is open, and an
/// application menu that does not feels broken long before anyone can say why.
class SlateMenuBar extends StatefulWidget {
  const SlateMenuBar({required this.children, super.key});

  final List<Widget> children;

  static _MenuBarCoordinator? _maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SlateMenuBarScope>()
      ?.coordinator;

  @override
  State<SlateMenuBar> createState() => _SlateMenuBarState();
}

class _MenuBarCoordinator {
  MenuController? _open;

  /// True while any menu in the bar is showing, which is what turns hovering
  /// into a menu switch.
  bool get isAnyOpen => _open != null;

  void opened(MenuController controller) {
    if (_open != null && !identical(_open, controller)) _open!.close();
    _open = controller;
  }

  void closed(MenuController controller) {
    if (identical(_open, controller)) _open = null;
  }
}

class _SlateMenuBarState extends State<SlateMenuBar> {
  final _MenuBarCoordinator _coordinator = _MenuBarCoordinator();

  @override
  Widget build(BuildContext context) {
    return _SlateMenuBarScope(
      coordinator: _coordinator,
      child: Row(mainAxisSize: MainAxisSize.min, children: widget.children),
    );
  }
}

class _SlateMenuBarScope extends InheritedWidget {
  const _SlateMenuBarScope({required this.coordinator, required super.child});

  final _MenuBarCoordinator coordinator;

  @override
  bool updateShouldNotify(_SlateMenuBarScope oldWidget) =>
      coordinator != oldWidget.coordinator;
}

/// A top-level menu: the label in a bar, and the panel it opens.
class SlateMenuButton extends StatefulWidget {
  const SlateMenuButton({required this.label, required this.items, super.key});

  final String label;

  /// Built lazily, so a menu reflects state that changed since it was last
  /// opened — a recent-files list, or a command that is now unavailable.
  final List<Widget> Function(BuildContext context) items;

  @override
  State<SlateMenuButton> createState() => _SlateMenuButtonState();
}

class _SlateMenuButtonState extends State<SlateMenuButton> {
  final MenuController _controller = MenuController();
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final bar = SlateMenuBar._maybeOf(context);

    return SlateMenuScope(
      controller: _controller,
      parent: null,
      child: MenuAnchor(
        controller: _controller,
        style: slateMenuStyle(theme),
        onOpen: () {
          bar?.opened(_controller);
          setState(() => _open = true);
        },
        onClose: () {
          bar?.closed(_controller);
          if (mounted) setState(() => _open = false);
        },
        menuChildren: <Widget>[
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items(context),
            ),
          ),
        ],
        builder: (context, controller, _) => _MenuLabel(
          label: widget.label,
          open: _open,
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          onHover: () {
            // Only takes over when the bar is already in use; hovering across a
            // closed menu bar must not open anything.
            if ((bar?.isAnyOpen ?? false) && !controller.isOpen) {
              controller.open();
            }
          },
        ),
      ),
    );
  }
}

class _MenuLabel extends StatefulWidget {
  const _MenuLabel({
    required this.label,
    required this.open,
    required this.onTap,
    required this.onHover,
  });

  final String label;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<_MenuLabel> createState() => _MenuLabelState();
}

class _MenuLabelState extends State<_MenuLabel> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final lit = widget.open || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: theme.metrics.controlHeight + 6,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: lit ? theme.palette.hover : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.metrics.radius),
          ),
          child: Text(widget.label, style: theme.textStyle),
        ),
      ),
    );
  }
}

/// One command in a menu.
class SlateMenuItem extends StatefulWidget {
  const SlateMenuItem({
    required this.label,
    this.shortcut,
    this.onPressed,
    this.checked = false,
    this.closesMenu = true,
    super.key,
  });

  final String label;

  /// Already formatted for display — the kit does not know the platform's
  /// conventions for naming modifier keys, and the app does.
  final String? shortcut;

  /// Null disables the row.
  final VoidCallback? onPressed;

  final bool checked;

  /// False for a toggle the user may want to hit several times.
  final bool closesMenu;

  @override
  State<SlateMenuItem> createState() => _SlateMenuItemState();
}

class _SlateMenuItemState extends State<SlateMenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final enabled = widget.onPressed != null;
    final ink = enabled
        ? theme.palette.ink
        : theme.palette.inkDim.withValues(alpha: 0.55);
    final scope = SlateMenuScope.maybeOf(context);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: enabled
            ? () {
                if (widget.closesMenu) scope?.closeAll();
                widget.onPressed!();
              }
            : null,
        child: Container(
          height: theme.metrics.rowHeight,
          constraints: const BoxConstraints(minWidth: 176),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: _hover && enabled
              ? theme.palette.selected
              : const Color(0x00000000),
          child: Row(
            children: <Widget>[
              // The gutter is always there, so a menu with one checked row does
              // not shift the labels of the rows around it.
              SizedBox(
                width: 16,
                child: widget.checked
                    ? SlateIcon(
                        SlateIcons.check,
                        size: 12,
                        color: theme.palette.accent,
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textStyle.copyWith(color: ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.shortcut != null) ...<Widget>[
                const SizedBox(width: 18),
                Text(
                  widget.shortcut!,
                  style: theme.dimTextStyle.copyWith(
                    color: enabled
                        ? theme.palette.inkDim
                        : theme.palette.inkDim.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row that opens a nested menu.
class SlateSubmenu extends StatefulWidget {
  const SlateSubmenu({required this.label, required this.items, super.key});

  final String label;
  final List<Widget> Function(BuildContext context) items;

  @override
  State<SlateSubmenu> createState() => _SlateSubmenuState();
}

class _SlateSubmenuState extends State<SlateSubmenu> {
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return SlateMenuScope(
      controller: _controller,
      parent: SlateMenuScope.maybeOf(context),
      child: MenuAnchor(
        controller: _controller,
        style: slateMenuStyle(theme),
        alignmentOffset: const Offset(4, -6),
        menuChildren: <Widget>[
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items(context),
            ),
          ),
        ],
        builder: (context, controller, _) => _SubmenuRow(
          label: widget.label,
          onEnter: controller.open,
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }
}

class _SubmenuRow extends StatefulWidget {
  const _SubmenuRow({
    required this.label,
    required this.onEnter,
    required this.onTap,
  });

  final String label;
  final VoidCallback onEnter;
  final VoidCallback onTap;

  @override
  State<_SubmenuRow> createState() => _SubmenuRowState();
}

class _SubmenuRowState extends State<_SubmenuRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        // Opening on hover is what makes a menu bar feel quick; a submenu that
        // needs a click reads as broken.
        widget.onEnter();
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: theme.metrics.rowHeight,
          constraints: const BoxConstraints(minWidth: 176),
          padding: const EdgeInsets.only(left: 26, right: 10),
          color: _hover ? theme.palette.selected : const Color(0x00000000),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(widget.label, style: theme.textStyle)),
              const SizedBox(width: 14),
              SlateIcon(
                SlateIcons.chevronRight,
                size: 12,
                color: theme.palette.inkDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The hairline between groups of commands.
class SlateMenuSeparator extends StatelessWidget {
  const SlateMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: theme.metrics.radius),
      color: theme.palette.separator,
    );
  }
}
