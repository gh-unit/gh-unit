require 'test/unit'
require 'ghunit'
require 'fileutils'
require 'zip/zip'

class GHUnitTest < Test::Unit::TestCase

  def unzip_file(file, destination)
    Zip::ZipFile.open(file) do |zip_file|
      zip_file.each do |f|
        next if f.name =~ /__MACOSX/ or f.name =~ /\.DS_Store/ or !f.file?
        f_path = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
     end
    end
  end

  def cleanup
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), "tmp"))
  end

  def tmp_dir
    File.join(File.dirname(__FILE__), "tmp")
  end

  def root_dir
    File.join(File.dirname(__FILE__), "..", "..")
  end

  def generate_empty_project_files
    cleanup

    FileUtils.mkdir_p(tmp_dir)
    src_zip = File.join(root_dir, "Examples", "Example-iOS.zip")
    dst_zip = File.join(tmp_dir, "Example-iOS.zip")
    FileUtils.cp(src_zip, dst_zip)

    unzip_file(dst_zip, tmp_dir)
    File.join(tmp_dir, "Example-iOS", "Example-iOS.xcodeproj")
  end

  def test
    project_path = generate_empty_project_files
    target_name = "Example-iOS"
    test_target_name = "Tests"

    puts "\n\n"

    project = GHUnit::Project.open(project_path, target_name, test_target_name)
    assert project.create_test_target

    # Run again, should only update
    project = GHUnit::Project.open(project_path, target_name, test_target_name)
    assert project.create_test_target

    # Write a podfile pointing at ourselves
    podfile_content =<<-EOS
platform :ios, '7.0'

target :Tests do
  pod 'GHUnit', :path => "../../../../"
end
EOS
    File.open("Podfile", "w") { |f| f.write(podfile_content) }

    system("pod install")
    system("open #{tmp_dir}/Example-iOS/Example-iOS.xcworkspace")
  end

end
