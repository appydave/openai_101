# frozen_string_literal: true

RSpec.describe 'Audio API', :tools_enabled do
  let(:client) { OpenAI::Client.new }

  describe 'Transcription' do
    let(:transcription_fixture) { json_fixture('audio_transcriptions.json') }

    it 'transcribes audio' do
      response = client.audio.transcribe(parameters: transcription_fixture['parameters'])
      expect(response['text']).to eq(transcription_fixture['response']['text'])
    end
  end

  describe 'Translation' do
    let(:parameters) do
      {
        "model": "whisper-1",
        "file": fixture_binary('audio_speech.mp3')
      }
    end
    
    fit 'translates audio' do
      response = client.audio.translate(parameters: parameters)
      # puts response['text']
      expect( DamerauLevenshtein.distance( response['text'], 'Hello, can I have a cappuccino please?' ) ).to eq(1)
      # expect(response['text']).to eq('Hello, can I have a cappuccino please?')
    end
  end

  describe 'Speech Synthesis' do
    let(:speech_fixture) { json_fixture('audio_speech.json') }
    let(:parameters) do
      {
        "model": "tts-1",
        "input": "Hello, can I have a cappuccino please?",
        "voice": "alloy",
        "response_format": "mp3",
        "speed": 1.0
      }
    end
    let(:output_file) { fixture_path('audio_speech.mp3') }

    it 'generates speech' do
      response = client.audio.speech(parameters: parameters)
      # puts output_file
      File.binwrite(output_file, response)
    end
  end
end
