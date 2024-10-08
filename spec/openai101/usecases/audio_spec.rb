# frozen_string_literal: true

# The main differences between translation and transcription services with OpenAI are their purposes and functionalities:

# Translation Service
#   - Purpose: Converts text from one language to another.
#   - Input: Text in the source language.
#   - Output: Text in the target language.
#   - Use Cases: Translating documents, websites, user interfaces, customer support conversations, etc.
#   - Example: Translating an English document to Spanish.
# Transcription Service
#   - Purpose: Converts spoken language (audio) into written text.
#   - Input: Audio or speech recording.
#   - Output: Text representing the spoken words.
#   - Use Cases: Transcribing interviews, lectures, meetings, podcasts, etc.
#   - Example: Converting a recorded meeting into a written transcript.


RSpec.describe 'Audio API', :tools_enabled do
  let(:client) { OpenAI::Client.new }
  let(:text_en) { 'Learn prompt engineering with Appy Dave' }
  let(:text_th) { 'เรียนรู้การสร้างคำสั่งกับแอพปี้ เดฟ' }
  let(:voices) { %w[alloy echo fable onyx nova shimmer] }
  let(:voice) { 'alloy' }
  let(:language) { 'en' }
  let(:audio_file_name) { "audio_speech-#{language}-#{voice}.mp3" }

  # https://platform.openai.com/docs/api-reference/audio/createTranscription
  describe 'Transcription' do
    let(:default_parameters) do
      {
        model: 'whisper-1',
        file: fixture_binary(audio_file_name)
      }
    end

    context 'when English language, voice: alloy' do
      let(:parameters) { default_parameters.merge(voice: 'alloy', language: 'en') }

      it 'transcribes audio' do
        response = client.audio.transcribe(parameters: parameters)
        puts response['text']
        expect(DamerauLevenshtein.distance(response['text'], text_en)).to be < 5
      end
    end

    context 'when English language, voice: nova' do
      let(:parameters) { default_parameters.merge(voice: 'nova', language: 'en') }

      it 'transcribes audio' do
        response = client.audio.transcribe(parameters: parameters)
        puts response['text']
        expect(DamerauLevenshtein.distance(response['text'], text_en)).to be < 5
      end
    end

    context 'when Thai language' do
      let(:language) { 'th' } # language is available for the Transcription API
      let(:parameters) { default_parameters.merge(voice: 'alloy', language: 'th') }

      it 'transcribes audio' do
        response = client.audio.transcribe(parameters: parameters)
        puts response['text']
        puts DamerauLevenshtein.distance(response['text'], text_th)
        expect(DamerauLevenshtein.distance(response['text'], text_th)).to be < 5
      end
    end
  end

  # https://platform.openai.com/docs/api-reference/audio/createTranslation
  describe 'Translation' do
    let(:default_parameters) do
      {
        model: 'whisper-1',
        file: fixture_binary(audio_file_name)
      }
    end

    # {
    #   "file": "path/to/audio/file.mp3",
    #   "model": "whisper-1",
    #   "prompt": "Please translate the following conversation with the barista.",
    #   "response_format": "json",
    #   "temperature": 0.5
    # }

    context 'with default parameters' do
      let(:parameters) { default_parameters }

      it 'translates audio' do
        response = client.audio.translate(parameters: parameters)
        # puts response['text']
        expect(DamerauLevenshtein.distance(response['text'], text_en)).to be < 5
      end
    end

    context 'with Thai language' do
      let(:language) { 'th' } # language is used for the file name only, its not used in the Translation API.
      let(:parameters) { default_parameters.merge(prompt: 'Someone named AppyDave') }

      it 'translates audio' do
        response = client.audio.translate(parameters: parameters)
        puts response['text']
        puts text_th
        puts text_en
        puts DamerauLevenshtein.distance(response['text'], text_en)
        expect(DamerauLevenshtein.distance(response['text'], text_en)).to be < 20
      end
    end

    context 'with response_format: [json, text, srt, verbose_json, or vtt]' do
      let(:parameters) { default_parameters.merge(response_format: 'srt') }
      #   WEBVTT

      #   00:00:00.000 --> 00:00:02.000
      #   Hello, can I have a cappuccino, please?#{'      '}
      # VTT
      # 1
      # 00:00:00,000 --> 00:00:02,000
      # Hello, can I have a cappuccino, please?
      # SRT

      it 'translates audio' do
        response = client.audio.translate(parameters: parameters)
        puts response
      end
    end
  end

  describe 'Speech Synthesis' do
    let(:voice) { 'alloy' }

    context 'when using English with selected voice' do
      let(:voice) { 'shimmer' }
      let(:parameters) do
        {
          model: 'tts-1',
          input: text_en,
          voice: voice,
          response_format: 'mp3',
          speed: 1.0
        }
      end

      it 'generates speech' do
        response = client.audio.speech(parameters: parameters)
        File.binwrite(audio_file_name, response)
      end
    end

    context 'when using Thai with selected voice' do
      let(:language) { 'th' } # language is used for the file name only, its not used in the API
      let(:parameters) do
        {
          model: 'tts-1',
          input: text_th,
          voice: voice,
          language: language,
          response_format: 'mp3',
          speed: 1.0
        }
      end

      it 'generates speech' do
        response = client.audio.speech(parameters: parameters)
        File.binwrite(audio_file_name, response)
      end
    end
  end
end
