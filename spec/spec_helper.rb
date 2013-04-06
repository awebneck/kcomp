$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'kcomp'
require 'fileutils'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

GOOD_SRC = File.dirname(__FILE__) + "/support/test-src"
CYCLIC_SRC_1 = File.dirname(__FILE__) + "/support/test-src-cyclic-1"
CYCLIC_SRC_2 = File.dirname(__FILE__) + "/support/test-src-cyclic-2"
MISSING_DEP_SRC = File.dirname(__FILE__) + "/support/test-src-missing-dependency"
UNDEFINED_VAR_SRC = File.dirname(__FILE__) + "/support/test-src-undefined-variable"
DEST = File.dirname(__FILE__) + "/support/test-dest"

RSpec.configure do |config|
  config.after :all do
    FileUtils.rm_r Dir.glob(DEST + "/*")
  end
end

def capture_stdout
  prev = $stdout
  $stdout = StringIO.new
  yield
  $stdout = prev
end
