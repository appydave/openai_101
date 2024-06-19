# frozen_string_literal: true

def fixture(file_name)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', file_name))
end

def fixture_path(file_name)
  File.join(File.dirname(__FILE__), 'fixtures', file_name)
end
