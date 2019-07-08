// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/analysis_server.dart';
import 'package:analysis_server/src/flutter/flutter_outline_computer.dart';
import 'package:analysis_server/src/protocol_server.dart' as protocol;
import 'package:analyzer/dart/analysis/results.dart';

void sendFlutterNotificationOutline(
    AnalysisServer server, ResolvedUnitResult resolvedUnit) {
  _sendNotification(server, () {
    var computer = new FlutterOutlineComputer(resolvedUnit);
    protocol.FlutterOutline outline = computer.compute();
    // send notification
    var params = new protocol.FlutterOutlineParams(
      resolvedUnit.path,
      outline,
    );
    server.sendNotification(params.toNotification());
  });
}

/**
 * Runs the given notification producing function [f], catching exceptions.
 */
void _sendNotification(AnalysisServer server, f()) {
  ServerPerformanceStatistics.notices.makeCurrentWhile(() {
    try {
      f();
    } catch (exception, stackTrace) {
      server.sendServerErrorNotification(
          'Failed to send notification', exception, stackTrace);
    }
  });
}
