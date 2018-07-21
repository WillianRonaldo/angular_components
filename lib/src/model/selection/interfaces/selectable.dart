// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Enum that specifies checkbox state for selectable item.
///
/// - Selectable - checkbox is visible and enabled.
/// - Disabled - the item is not selectable, checkbox is visible but disabled
///              (ideally with explanation in the tooltip).
/// - Hidden - the item is not selectable, and no checkbox is present.
enum SelectableOption { Selectable, Disabled, Hidden }

typedef SelectableGetter<T> = SelectableOption Function(T entity);

/// Interface for determining if an entity [T] should be shown as selectable.
///
/// This interface is designed to allow metadata to determine if in a given list
/// of selectable entities if certain entities should be shown to the user but
/// not be selectable themselves within the UI.
///
/// __Example use__:
///     class MySelectionOptions = SelectionOptions with Selectable;
abstract class Selectable<T> {
  /// Whether [item] should be shown as selectable.
  SelectableOption getSelectable(T item) => SelectableOption.Selectable;
}

/// Interface for determining if an entity [T] should be shown as selectable.
///
/// This interface serves the same purpose of Selectable<T>, except the
/// getSelectable getter is a member instead of a method.
///
/// __Example use__:
///     class MySelectionOptions = SelectionOptions with SelectableWithComposition;
///
/// **DEPRECATED**: The main purpose of this interface/class was to have an
/// indentical API to [Selectable], but allow overriding the [getSelectable]
/// implementation at runtime. Unfortunately this has caused many problems
/// (b/111665960), and in practice users were using this interface but providing
/// a static implementation. To get a similar API, simply extend/mixin/implement
/// [SelectableWithOverride].
@Deprecated('Being removed in favor of `SelectableWithOverride`')
abstract class SelectableWithComposition<T> {
  /// Whether [item] should be shown as selectable.
  SelectableGetter<T> getSelectable = (T item) => SelectableOption.Selectable;
}

/// Interface for determining if an entity [T] should be shown as selectable.
///
/// This interface serves the same purpose of `Selectable<T>`, except the
/// [getSelectable] method delegates to [overrideGetSelectable], which can be
/// invoked at runtime.
///
/// It is recommended to _extend_ or _mixin_ this class when possible.
///
/// __Example use__:
///     class MySelectionOptions = SelectionOptions with SelectableWithOverride;
abstract class SelectableWithOverride<T> implements Selectable<T> {
  @override
  SelectableOption getSelectable(T item) => _overrideSelectable(item);

  /// May be set, at runtime, to change the implementation of [getSelectable].
  void overrideGetSelectable(SelectableGetter<T> overrideSelectable) {
    _overrideSelectable = override;
  }

  SelectableGetter<T> _overrideSelectable = (_) => SelectableOption.Selectable;
}

/// An optional interface for describing why an item is/is not selectable.
///
/// __Example use__:
///     MaterialSuggestItem(@Optional() HasSelectableRationale rationale) {
///       // May use rationale.getSelectableRationale to show a tooltip.
///     }
///
/// It is recommended you always make this optional when injecting, or default
/// to [HasSelectionRationale.none] to avoid null checks:
///     selectionRationale ??= const HasSelectionRationale.none();
abstract class HasSelectionRationale<T> {
  /// Create a default [HasSelectionRationale] that always returns `null`.
  const factory HasSelectionRationale.none() = _NullHasSelectionRationale<T>;

  /// Returns a string describing why [item] on why [isSelectable].
  ///
  /// This may be used in the UI to for example, show a tooltip explaining that
  /// the current user lacks privileges to select an item:
  ///     @override
  ///     String getSelectableRationale(T item, [bool isSelectable = false]) {
  ///       if (!isSelectable && (item as FooItem).lacksPrivileges) {
  ///         return 'You lack privileges to select this item.';
  ///       }
  ///     }
  ///
  /// Or to explain why you are able to access certain items:
  ///     @override
  ///     String getSelectableRationale(T item, [bool isSelectable = false]) {
  ///       if (isSelectable && CURRENT_USER.isManager) {
  ///         return 'As a manager, you may select this option.';
  ///       }
  ///     }
  String getSelectableRationale(T item, [bool isSelectable = false]);
}

class _NullHasSelectionRationale<T> implements HasSelectionRationale<T> {
  const _NullHasSelectionRationale();

  @override
  String getSelectableRationale(T item, [bool isSelectable = false]) => null;
}
