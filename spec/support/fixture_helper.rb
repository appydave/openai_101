# frozen_string_literal: true

module FixtureHelper
  def fixture_path(file_name)
    File.expand_path(File.join(File.dirname(__FILE__), '../fixtures', file_name))
  end

  def fixture(file_name)
    File.read(fixture_path(file_name))
  end

  def fixture_binary(file_name)
    File.open(fixture_path(file_name), 'rb')
  end

  def json_fixture(file_name)
    JSON.parse(fixture(file_name))
  end
end
