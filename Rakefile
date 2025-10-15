require 'rspec/core/rake_task'
require 'fileutils'
require_relative 'utils/rake_helpers'
require_relative 'utils/jenkins/results_parser'
require_relative 'utils/jenkins/ad_hoc_auto_runner'
require_relative 'utils/jira/jira_util'

# Rake tasks to run automated tests
# @example: Run tests against remote server and generate XML JUnit output
#   rake remote[cloudwall]
# @example: Run tests against remote server and don't generate XML output
#   rake remote[cloudwall,false]
# @note
#   When specifying multiple parameters to your rake task on the command-line, you must quote them
#   like this "remote[cloudwall, false]" or omit the space between the parameters, like this: remote[cloudwall,false]

# Main task responsible for launching RSpec
# @param :config_file The environment config
# @param :application The specs subfolder to run tests for
# @param :xml_output Whether to generate JUnit-compatible XML test result output
# @param :tag will run only the tests with the specific tag
desc ''
RSpec::Core::RakeTask.new(:spec, :config_file, :application, :xml_output, :tag, :rerun) do |t, args|
  t.pattern = "specs/#{args[:application]}"
  options = rspec_config_to_options(args)
  puts "Using rspec options #{options}"
  t.rspec_opts = options
end

desc 'Run tests locally against a local Tomcat instance'
task :dev, [:application, :xml_output, :tag] do |t, args|
  args.with_defaults :xml_output => 'false', :tag => ''
  Rake::Task['spec'].invoke('env_local_dev.rb', args[:application], args[:xml_output], args[:tag])
end

desc 'Run tests locally against a remote server'
task :local, [:application, :xml_output, :tag] do |t, args|
  args.with_defaults :xml_output => 'true', :tag => ''
  Rake::Task['spec'].invoke('env_local.rb', args[:application], args[:xml_output], args[:tag])
end

desc 'Run tests locally using Chrome Headless against a remote server'
task :headless, [:application, :xml_output, :tag] do |t, args|
  args.with_defaults :xml_output => 'true', :tag => ''
  Rake::Task['spec'].invoke('env_local_headless.rb', args[:application], args[:xml_output], args[:tag])
end

# Run tests in the cloud, in parallel, by application and by tag
# @note you can specify a single tag, or multiple tags
# @example: Run tests within an application by a single tag
#   rake cloud[cloudwall,false,~wip]
# @example: Run tests within an application by multiple tags
#   rake cloud[cloudwall,false,'~wip ~slow']

desc 'Run tests locally without a visible browser window in parallel (Linux only)'
task :parallel, [:application, :xml_output, :tags] do |t, args|
  ENV['XML_OUTPUT'] = args[:xml_output].to_s
  run(config: 'env_local_headless.rb', tags: args[:tags], application: args[:application])
end

desc 'Run tests in parallel on a Selenium Grid instance, automatically rerunning failures'
task :grid, [:application, :xml_output, :tags] do |t, args|
  parse_results = args[:tags].include? 'autoparse'
  tags_to_run = args[:tags].split(' ').reject{|a| a == 'autoparse'}.join(' ')

  ENV['XML_OUTPUT'] = args[:xml_output].to_s
  run(config: 'env_grid.rb', tags: tags_to_run, application: args[:application])
  final_results = ['tmp/results.xml']

  unless $?.success?
    puts "Rerunning failed tests..."
    rerun_xml_output =
      if args[:xml_output] == 'true'
        'tmp/rerun_results.xml'
      else
        'false'
      end
    rspec_options = rspec_config_to_options({
      config_file: 'env_grid.rb',
      xml_output: rerun_xml_output,
      tag: args[:tag],
      rerun: true
    })
    puts "Using rspec options #{rspec_options}"
    system("rspec #{rspec_options} specs/#{args[:application]}")
    final_results.unshift('tmp/rerun_results.xml')
  end

  if args[:xml_output] == 'true'
    puts 'Merging rerun results into results.xml...'
    junit_merge(*Dir.glob('tmp/results*.xml').concat(final_results))

    puts 'Removing unnecessary results XML files'
    FileUtils.rm(Dir.glob('tmp/*results*.xml').reject { |f| f == final_results.last })
  end

  if parse_results
    tmp_path = File.join(Dir.pwd, 'tmp')
    puts 'Parsing results.xml file and generating CSV file'
    parser = XMLResultsParser.new('results.xml', tmp_path)

    # for now we are only creating Jira tickets for the listed applications below
    if %w(CloudWall MAT MAC SIA OrderApp Book DBAquent CardSearch OnboardingApp CustomInvoicing TimeAwayApp TalentHappyPath CreateOrderApi LRO PRDS PayrollReports CeridianPayroll ScheduledJobs Invoices).include? parser.epic_link
      JiraUtil.new(parser.file).update_jira_issues
    end

  end
end

desc 'Run tests in parallel on a Selenium Grid instance'
task :grid_no_rerun, [:application, :xml_output, :tags] do |t, args|
  ENV['XML_OUTPUT'] = args[:xml_output].to_s
  run(config: 'env_grid.rb', tags: args[:tags], application: args[:application])
end

desc 'Runs payroll on a Selenium Grid instance'
task :ceridian_run_payroll_task do
  ENV['XML_OUTPUT'] = 'true'
  run(config: 'env_grid.rb', tags: 'ceridian_run_payroll_verify', application: 'cloudwall')
end

desc 'Creates a text file containing all failing test names'
task :collect_all_results do
  ENV['XML_OUTPUT'] = 'true'
  tmp_path = File.join(Dir.pwd, 'tmp')

  Dir.mkdir tmp_path unless File.exist? tmp_path

  FileUtils.rm(Dir.glob('tmp/*results.xml'))

  ResultsCollector.new(tmp_path)
end

desc 'Runs the ad-hoc job with the list of failing test names'
task :auto_run_ad_hoc_job do
  include AdHocRunner

  test_list = get_test_list
  raise 'Test list could not be found' if test_list.nil?
  start_ad_hoc_job(test_list)
end

desc 'Parse the results from the auto-ad-hoc run'
task :parse_ad_hoc_results do
  tmp_path = File.join(Dir.pwd, 'tmp')
  puts tmp_path
  puts 'Parsing results.xml file and generating CSV file'
  parser = XMLResultsParser.new('results.xml', tmp_path)

  JiraUtil.new(parser.file).update_passing_tests
end

# Rake tasks to generate a list of tags
namespace :tags do

  # Common actions to generate a tag report
  def list_tags
    require_relative 'utils/tag_helper'
    TagHelper.list_tags
  end

  # Generate a list of tags alphabetically by type
  # @example: With verbose output enabled
  #   rake tags:by_type
  # @example: With verbose output disabled
  #   rake tags:by_type['off']
  desc 'List tags alphabetically by type'
  task :by_type, [:verbosity] do |t, args|
    ENV['LIST_TAGS'] = 'on'
    ENV['TAG_SORT_ORDER'] = 'alphabetical'
    ENV['TAG_VERBOSITY'] = args[:verbosity] || 'high'
    list_tags
  end

  # Generate a list of tags by number of uses
  # @example: With verbose output enabled
  #   rake tags:by_use
  # @example: With verbose output disabled
  #   rake tags:by_use['off']
  desc 'List tags by number of uses (descending)'
  task :by_use, [:verbosity] do |t, args|
    ENV['LIST_TAGS'] = 'on'
    ENV['TAG_SORT_ORDER'] = 'descending'
    ENV['TAG_VERBOSITY'] = args[:verbosity] || 'high'
    list_tags
  end
end
