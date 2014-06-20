library app_bootstrap;

import 'package:polymer/polymer.dart';

import '../lib/graph-canvas/graph-canvas.dart' as i0;
import 'dijkstra.html.0.dart' as i1;
import 'package:smoke/smoke.dart' show Declaration, PROPERTY, METHOD;
import 'package:smoke/static.dart' show useGeneratedCode, StaticConfiguration;
import '../lib/graph-canvas/graph-canvas.dart' as smoke_0;
import 'package:polymer/polymer.dart' as smoke_1;

void main() {
  useGeneratedCode(new StaticConfiguration(
      checkedMode: false,
      parents: {
        smoke_0.GraphCanvasTag: smoke_1.PolymerElement,
      },
      declarations: {
        smoke_0.GraphCanvasTag: const {},
      }));
  configureForDeployment([
      () => Polymer.register('graph-canvas', i0.GraphCanvasTag),
    ]);
  i1.main();
}
