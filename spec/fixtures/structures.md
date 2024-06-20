# Structures

The following stretches need to be passed through a ChatGPT and converted into JSON configuration objects.

## Speech

## Language Support:

- Afrikaans, Arabic, Armenian, Azerbaijani, Belarusian, Bosnian, Bulgarian, Catalan, Chinese,
- Croatian, Czech, Danish, Dutch, English, Estonian, Finnish, French, Galician, German, Greek,
- Hebrew, Hindi, Hungarian, Icelandic, Indonesian, Italian, Japanese, Kannada, Kazakh, Korean,
- Latvian, Lithuanian, Macedonian, Malay, Marathi, Maori, Nepali, Norwegian, Persian, Polish,
- Portuguese, Romanian, Russian, Serbian, Slovak, Slovenian, Spanish, Swahili, Swedish, Tagalog,
- Tamil, Thai, Turkish, Ukrainian, Urdu, Vietnamese, and Welsh.

### Models

tts-1
tts-1-hd

### Speech Response Format:

- json
- text
- srt
- verbose_json
- vtt

### Voices

- alloy
- echo
- fable
- onyx
- nova
- shimmer

### Audio Output Formats

Opus: For internet streaming and communication, low latency.
AAC: For digital audio compression, preferred by YouTube, Android, iOS.
FLAC: For lossless audio compression, favored by audio enthusiasts for archiving.
WAV: Uncompressed WAV audio, suitable for low-latency applications to avoid decoding overhead.
PCM: Similar to WAV but containing the raw samples in 24kHz (16-bit signed, low-endian), without the header.

### Create transcription

File: Audio object, not file name in formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm
Model: tts-1 or tts-1-hd
Language: en in ISO-639-1 format will improve accuracy and latency.
Prompt: Optional text to guide the model's style or continue a previous audio segment, should match the audio language.
Response Format: json, text, srt, verbose_json, or vtt (default: json)
Temperature: Sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. If set to 0, the model will use log probability to automatically increase the temperature until certain thresholds are hit.
Timestamp Granularities: word, segment, or both. Note: There is no additional latency for segment timestamps, but generating word timestamps incurs additional latency.

Note: Reponse should be verbose_json for timestamps.

```json
{
  "file": "file",
  "model": "tts-1",
  "language": "en",
  "voice": "nova",
  "response_format": "json",
  "audio_format": "opus"
}
























