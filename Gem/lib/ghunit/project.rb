require 'xcodeproj'
require 'fileutils'
require 'logger'
require 'colorize'
require 'erb'
require 'ostruct'

class ErbalT < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end

class GHUnit::Project

  attr_reader :project_path, :target_name, :test_target_name, :logger

  attr_reader :project, :main_target

  def initialize(project_path, target_name, test_target_name, logger=nil)
    @target_name = target_name
    @project_path = project_path
    @test_target_name = test_target_name
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.formatter = proc do |severity, datetime, progname, msg|
        case severity
        when "ERROR"
          "#{msg}\n".red
        when "DEBUG"
          "#{msg}\n".green
        else
          "#{msg}\n"
        end
      end
      logger
    end
  end

  def open
    if !File.exists?(project_path)
      logger.error "Can't find project path at #{project_path}"
      return false
    end

    @project = Xcodeproj::Project.open(project_path)

    # Find the main target for the test dependency
    @main_target = project.targets.select { |t| t.name == target_name }.first
    if !@main_target
      logger.error "No target with name #{target_name}"
      return false
    end

    true
  end

  class << self

    # Initialize and open a project.
    #
    def open(project_path, target_name, test_target_name, logger=nil)
      project = GHUnit::Project.new(project_path, target_name, test_target_name, logger)
      if project.open
        project
      else
        nil
      end
    end

    # Open from slop options.
    # This is only meant to be called from the ghunit bin executable,
    # it outputs to STDOUT and calls exit.
    #
    def open_from_opts(opts)
      target_name = opts[:name]
      project_path = opts[:path] || "#{target_name}.xcodeproj"
      test_target_name = opts[:test_target] || "Tests"

      if !target_name
        puts " "
        puts "Need to specify a project name.".red
        puts " "
        puts opts.to_s
        puts " "
        exit 1
      end

      self.open(project_path, target_name, test_target_name)
    end
  end

  def find_test_target
    project.targets.select { |t| t.name == test_target_name }.first
  end

  # Create the test target and setup everything
  #
  def create_test_target
    Dir.chdir(File.dirname(project_path))
    FileUtils.mkdir_p(test_target_name)

    # Write the Tests-Info.plist
    test_info = {
      "CFBundleDisplayName" => "${PRODUCT_NAME}",
      "CFBundleExecutable" => "${EXECUTABLE_NAME}",
      "CFBundleIdentifier" =>  "tests.${PRODUCT_NAME:rfc1034identifier}",
      "CFBundleInfoDictionaryVersion" => "6.0",
      "CFBundleName" => "${PRODUCT_NAME}",
      "CFBundlePackageType" => "APPL",
      "CFBundleShortVersionString" => "1.0",
      "CFBundleVersion" => "1.0",
      "LSRequiresIPhoneOS" => true,
      "UISupportedInterfaceOrientations" => ["UIInterfaceOrientationPortrait"]
    }
    test_info_path = File.join(test_target_name, "#{test_target_name}-Info.plist")
    if !File.exists?(test_info_path)
      logger.debug "Creating: #{test_info_path}"
      Xcodeproj.write_plist(test_info, test_info_path)
    else
      logger.debug "#{test_info_path} already exists, skipping..."
    end

    test_target = find_test_target
    if !test_target

      # Create the test target
      logger.debug "Creating target: #{test_target_name}"
      test_target = project.new_target(:application, test_target_name, :ios, "7.0")
      test_target.add_dependency(main_target)

      create_test_file("main.m", template("main.m"), true)
      create_test("MyTest")

      #
      # No longer doing this (using same resource build phase as main target).
      # It causes crashes in latest xCode.
      #
      # Use same resources build phase as main target
      # Have to compare with class name because of funky const loading in xcodeproj gem
      # resources_build_phase = main_target.build_phases.select { |p|
      #   p.class == Xcodeproj::Project::Object::PBXResourcesBuildPhase }.first
      # test_target.build_phases << resources_build_phase if resources_build_phase

      # Add resources build phase if one doesn't exist
      resources_build_phase = test_target.build_phases.select { |p|
        p.class == Xcodeproj::Project::Object::PBXResourcesBuildPhase }.first

      test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXResourcesBuildPhase) unless resources_build_phase
    else
      logger.debug "Test target already exists, skipping..."
    end

    # Get main target prefix header
    debug_settings = main_target.build_settings("Debug")
    prefix_header = debug_settings["GCC_PREFIX_HEADER"] if debug_settings

    # Clear default OTHER_LDFLAGS (otherwise CocoaPods gives a warning)
    test_target.build_configurations.each do |c|
      c.build_settings.delete("OTHER_LDFLAGS")
      c.build_settings["INFOPLIST_FILE"] = test_info_path
      c.build_settings["GCC_PREFIX_HEADER"] = prefix_header if prefix_header
    end

    # Write any test support files
    write_test_file("RunTests.sh", template("RunTests.sh"), true)

    # Create test scheme if it doesn't exist
    logger.debug "Checking for Test scheme..."
    schemes = Xcodeproj::Project.schemes(project_path)
    test_scheme = schemes.select { |s| s == test_target_name }.first
    if !test_scheme
      logger.debug "Test scheme not found, creating..."
      scheme = Xcodeproj::XCScheme.new
      scheme.set_launch_target(test_target)
      scheme.save_as(project_path, test_target_name)
    else
      logger.debug "Test scheme already exists, skipping..."
    end

    logger.debug "Saving project..."
    project.save

    check_pod
  end

  def template(name, template_vars=nil)
    template_path = File.join(File.dirname(__FILE__), "templates", name)
    content = File.read(template_path)

    if template_path.end_with?(".erb")
      et = ErbalT.new(template_vars)
      content = et.render(content)
    end
    content
  end

  def write_test_file(file_name, content, force=false)
    # Create file in tests dir
    path = File.join(test_target_name, file_name)

    if !force && File.exists?(path)
      logger.info "Test file already exists, skipping"
    end

    logger.debug "Creating: #{path}"
    File.open(path, "w") { |f| f.write(content) }
    path
  end

  # Create a file with content and add to the test target
  #
  def create_test_file(file_name, content, force=false)
    path = write_test_file(file_name, content, force)
    add_test_file(path)
    path
  end

  # Add a file to the test target
  #
  def add_test_file(path)
    test_target = find_test_target
    if !test_target
      logger.error "No test target to add to"
      return false
    end

    tests_group = project.groups.select { |g| g.name == test_target_name }.first
    tests_group ||= project.new_group(test_target_name)

    test_file = tests_group.find_file_by_path(path)
    if !test_file
      test_file = tests_group.new_file(path)
    end
    test_target.add_file_references([test_file])
    true
  end

  # Create test file and add it to the test target.
  #
  # @param name Name of test class and file name
  # @param template_type nil or "kiwi"
  #
  def create_test(name, template_type=nil)
    template_type ||= :ghunit

    template_name = case template_type.to_sym
    when :kiwi
      "TestKiwi.m.erb"
    when :ghunit
      "Test.m.erb"
    end

    if name.end_with?(".m")
      name = name[0...-2]
    end
    template_vars = {test_class_name: name}
    path = create_test_file("#{name}.m", template(template_name, template_vars))
    path
  end

  def save
    @project.save
  end

  # Check the Podfile or just display some Podfile help
  #
  def check_pod
    logger.info <<-EOS

Add the following to your Podfile and run pod install.

#{template("Podfile")}

Make sure to open the .xcworkspace.

EOS
  end

  def sync_test_target_membership
    test_target = find_test_target
    if !test_target
      logger.error "No test target to add to"
      return false
    end

    tests_group = project.groups.select { |g| g.name == test_target_name }.first
    if !tests_group
      logger.error "No test group to add to"
      return false
    end

    sources_phase = main_target.build_phases.select { |p|
      p.class == Xcodeproj::Project::Object::PBXSourcesBuildPhase }.first

    if !sources_phase
      logger.error "No main target source phase found"
      return false
    end

    logger.debug "Adding to test target: "
    sources_phase.files_references.each do |file_ref|
      next if file_ref.path == "main.m"
      test_file = tests_group.find_file_by_path(file_ref.path)
      if !test_file
        logger.debug "  #{file_ref.path}"
        test_target.add_file_references([file_ref])
      end
    end
    project.save
  end

  def install_run_tests_script
    run_script_name = "Run Tests (CLI)"
    # Find run script build phase and install RunTests.sh
    test_target = find_test_target
    run_script_phase = test_target.build_phases.select { |p|
      p.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase &&
      p.name == run_script_name }.first
    if !run_script_phase
      logger.debug "Installing run tests script..."
      run_script_phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
      run_script_phase.name = run_script_name
      run_script_phase.shell_script = "sh Tests/RunTests.sh"
      test_target.build_phases << run_script_phase
    end
    project.save
  end
end
