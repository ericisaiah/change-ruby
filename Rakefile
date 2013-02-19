require 'rake/testtask'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :default => :test
