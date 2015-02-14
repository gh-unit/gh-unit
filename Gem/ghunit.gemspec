Gem::Specification.new do |s|
  s.name = "ghunit"
  s.version = "1.0.6"
  s.executables << "ghunit"
  s.date = "2014-07-14"
  s.summary = "GHUnit"
  s.description = "Utilities for GHUnit iOS/MacOSX test framework."
  s.authors = ["Gabriel Handford"]
  s.email = "gabrielh@gmail.com"
  s.files = Dir.glob("{lib}/**/*")
  s.homepage = "https://github.com/gh-unit/gh-unit"
  s.license = "MIT"
  s.add_runtime_dependency "xcodeproj", "~> 0.21.2"
  s.add_runtime_dependency "slop", "~> 3"
  s.add_runtime_dependency "colorize", "~> 0.7.5"
  s.add_runtime_dependency "xcpretty", "~> 0.1.7"
end
