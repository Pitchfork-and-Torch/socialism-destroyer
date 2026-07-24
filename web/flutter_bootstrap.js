{{flutter_js}}
{{flutter_build_config}}

// Prefer local canvaskit/ shipped with the build. Also allow gstatic in CSP as fallback.
if (_flutter.buildConfig) {
  _flutter.buildConfig.useLocalCanvasKit = true;
}

// No Flutter service worker — stale SW caches pinned broken CanvasKit CDN loads.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "/canvaskit/",
  },
});
