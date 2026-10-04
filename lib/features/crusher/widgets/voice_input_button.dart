import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../themes/themes.dart';

/// Mic toggle that streams recognized speech into a text callback.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onTranscript,
    this.size = 48,
  });

  final void Function(String text) onTranscript;
  final double size;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = SpeechToText();
  bool _ready = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _ready = await _speech.initialize(
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            if (mounted) setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
      if (mounted) setState(() {});
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> _toggle() async {
    if (!_ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input is not available on this device.'),
          ),
        );
      }
      return;
    }

    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          widget.onTranscript(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  @override
  void dispose() {
    if (_listening) _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final enabled = _ready || kIsWeb;

    return Semantics(
      label: _listening ? 'Stop voice input' : 'Start voice input',
      button: true,
      child: Material(
        color: _listening
            ? sd.accentRed.withValues(alpha: 0.2)
            : sd.accentGold.withValues(alpha: 0.15),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? _toggle : null,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              _listening ? Icons.mic : Icons.mic_none_rounded,
              color: _listening ? sd.accentRed : sd.accentGold,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}