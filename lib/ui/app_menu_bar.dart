import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controller/document_controller.dart';
import '../core/settings/settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_actions.dart';

/// The application menu, rendered in-app rather than through a GTK menu bar.
///
/// Flutter's [PlatformMenuBar] has no Linux backend, and an in-app menu keeps
/// the sober theme consistent across the whole window.
class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = AppActions(context);
    final documents = context.watch<DocumentController>();
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    final recentFiles = settings.recentFiles;

    // No height or background of its own: it is embedded in WindowBar, which
    // supplies both so the menus and the window buttons read as one bar.
    return MenuBar(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      children: <Widget>[
        SubmenuButton(
          menuChildren: <Widget>[
            _item(
              l10n.actionNew,
              const SingleActivator(LogicalKeyboardKey.keyN, control: true),
              actions.newImage,
            ),
            _item(
              l10n.actionOpen,
              const SingleActivator(LogicalKeyboardKey.keyO, control: true),
              actions.open,
            ),
            _item(
              l10n.actionSave,
              const SingleActivator(LogicalKeyboardKey.keyS, control: true),
              actions.save,
            ),
            _item(
              l10n.actionSaveAs,
              const SingleActivator(
                LogicalKeyboardKey.keyS,
                control: true,
                shift: true,
              ),
              actions.saveAs,
            ),
            const Divider(height: 1),
            SubmenuButton(
              menuChildren: <Widget>[
                if (recentFiles.isEmpty)
                  MenuItemButton(
                    onPressed: null,
                    child: Text(l10n.actionNoRecentFiles),
                  )
                else ...<Widget>[
                  for (final path in recentFiles)
                    MenuItemButton(
                      onPressed: () => actions.openPath(path),
                      child: Text(
                        path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Divider(height: 1),
                  MenuItemButton(
                    onPressed: settings.clearRecentFiles,
                    child: Text(l10n.actionClearRecentFiles),
                  ),
                ],
              ],
              child: Text(l10n.actionRecentFiles),
            ),
            const Divider(height: 1),
            _item(
              l10n.actionQuit,
              const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
              () => _quit(context),
            ),
          ],
          child: Text(l10n.menuFile),
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            _item(
              l10n.actionUndo,
              const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
              documents.canUndo ? actions.undo : null,
            ),
            _item(
              l10n.actionRedo,
              const SingleActivator(LogicalKeyboardKey.keyY, control: true),
              documents.canRedo ? actions.redo : null,
            ),
            const Divider(height: 1),
            _item(
              l10n.actionCut,
              const SingleActivator(LogicalKeyboardKey.keyX, control: true),
              actions.cut,
            ),
            _item(
              l10n.actionCopy,
              const SingleActivator(LogicalKeyboardKey.keyC, control: true),
              actions.copy,
            ),
            _item(
              l10n.actionPaste,
              const SingleActivator(LogicalKeyboardKey.keyV, control: true),
              actions.paste,
            ),
            _item(
              l10n.actionDelete,
              const SingleActivator(LogicalKeyboardKey.delete),
              actions.deleteSelection,
            ),
            const Divider(height: 1),
            _item(
              l10n.actionSelectAll,
              const SingleActivator(LogicalKeyboardKey.keyA, control: true),
              actions.selectAll,
            ),
            _item(
              l10n.actionDeselect,
              const SingleActivator(
                LogicalKeyboardKey.keyA,
                control: true,
                shift: true,
              ),
              actions.deselect,
            ),
            _item(l10n.actionInvertSelection, null, actions.invertSelection),
            _item(
              l10n.actionCropToSelection,
              const SingleActivator(
                LogicalKeyboardKey.keyX,
                control: true,
                shift: true,
              ),
              actions.cropToSelection,
            ),
            const Divider(height: 1),
            _item(l10n.actionPasteFrom, null, actions.pasteFrom),
            _item(l10n.actionCopyTo, null, actions.copyTo),
          ],
          child: Text(l10n.menuEdit),
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            _item(
              l10n.actionZoomIn,
              const SingleActivator(LogicalKeyboardKey.equal, control: true),
              actions.zoomIn,
            ),
            _item(
              l10n.actionZoomOut,
              const SingleActivator(LogicalKeyboardKey.minus, control: true),
              actions.zoomOut,
            ),
            _item(
              l10n.actionZoomNormal,
              const SingleActivator(LogicalKeyboardKey.digit0, control: true),
              actions.zoomActualSize,
            ),
            _item(
              l10n.actionZoomFit,
              const SingleActivator(LogicalKeyboardKey.digit9, control: true),
              actions.zoomFit,
            ),
            const Divider(height: 1),
            SubmenuButton(
              menuChildren: <Widget>[
                for (final mode in ThemeMode.values)
                  RadioMenuButton<ThemeMode>(
                    value: mode,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) actions.setThemeMode(value);
                    },
                    child: Text(switch (mode) {
                      ThemeMode.system => l10n.themeSystem,
                      ThemeMode.light => l10n.themeLight,
                      ThemeMode.dark => l10n.themeDark,
                    }),
                  ),
              ],
              child: Text(l10n.actionToggleTheme),
            ),
          ],
          child: Text(l10n.menuView),
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            _item(l10n.imageFlipHorizontal, null, actions.flipHorizontal),
            _item(l10n.imageFlipVertical, null, actions.flipVertical),
            const Divider(height: 1),
            _item(l10n.imageRotate90Right, null, () => actions.rotate(1)),
            _item(l10n.imageRotate90Left, null, () => actions.rotate(3)),
            _item(l10n.imageRotate180, null, () => actions.rotate(2)),
            const Divider(height: 1),
            _item(
              l10n.imageResize,
              const SingleActivator(LogicalKeyboardKey.keyR, control: true),
              actions.resizeImage,
            ),
            _item(l10n.imageCanvasSize, null, actions.canvasSize),
            _item(
              l10n.imageStretchSkew,
              const SingleActivator(LogicalKeyboardKey.keyW, control: true),
              actions.stretchAndSkew,
            ),
            const Divider(height: 1),
            _item(
              l10n.imageInvertColors,
              const SingleActivator(LogicalKeyboardKey.keyI, control: true),
              actions.invertColors,
            ),
            _item(l10n.imageClear, null, actions.clearImage),
          ],
          child: Text(l10n.menuImage),
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            MenuItemButton(
              onPressed: () => _showAbout(context),
              child: Text(l10n.actionAbout),
            ),
          ],
          child: Text(l10n.menuHelp),
        ),
      ],
    );
  }

  static Widget _item(
    String label,
    MenuSerializableShortcut? shortcut,
    VoidCallback? onPressed,
  ) {
    return MenuItemButton(
      shortcut: shortcut,
      onPressed: onPressed,
      child: Text(label),
    );
  }

  static Future<void> _quit(BuildContext context) async {
    if (await AppActions(context).confirmClose()) {
      // Popping the root route ends the app on desktop.
      if (context.mounted) await Navigator.of(context).maybePop();
    }
  }

  static void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: appVersion,
      applicationIcon: const _AboutIcon(),
      children: <Widget>[Text(l10n.aboutDescription)],
    );
  }
}

/// Version string, replaced at build time by `tools/set_version.sh`.
const String appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '0.1.0',
);

class _AboutIcon extends StatelessWidget {
  const _AboutIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/paint.png', width: 48, height: 48);
  }
}
