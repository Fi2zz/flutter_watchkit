import 'package:flutter/foundation.dart';

enum WatchConnectionKind {
  disabled,
  connecting,
  connected,
  waitingWatch,
  watchAppMissing,
  unpaired,
  unsupported,
}

@immutable
class WatchStatus {
  const WatchStatus({required this.kind, required this.connected});

  const WatchStatus.disabled()
    : this(kind: WatchConnectionKind.disabled, connected: false);

  const WatchStatus.connecting()
    : this(kind: WatchConnectionKind.connecting, connected: false);

  const WatchStatus.connected()
    : this(kind: WatchConnectionKind.connected, connected: true);

  const WatchStatus.waitingWatch()
    : this(kind: WatchConnectionKind.waitingWatch, connected: false);

  const WatchStatus.watchAppMissing()
    : this(kind: WatchConnectionKind.watchAppMissing, connected: false);

  const WatchStatus.unpaired()
    : this(kind: WatchConnectionKind.unpaired, connected: false);

  const WatchStatus.unsupported()
    : this(kind: WatchConnectionKind.unsupported, connected: false);

  final WatchConnectionKind kind;
  final bool connected;
}
