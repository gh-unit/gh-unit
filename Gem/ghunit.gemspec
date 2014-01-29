Gem::Specification.new do |s|
  s.name = "ghunit"
  s.version = "1.0.0"
  s.executables << "ghunit"
  s.date = "2014-01-29"
  s.summary = "GHUnit"
  s.description = "Utilities for GHUnit iOS/MacOSX test framework."
  s.authors = ["Gabriel Handford"]
  s.email = "gabrielh@gmail.com"
  s.files = ["lib/ghunit.rb", "lib/ghunit/project.rb", "lib/ghunit/templates/Podfile", "lib/ghunit/templates/Test.m", "lib/ghunit/templates/main.m"]
  s.homepage = "https://github.com/gh-unit/gh-unit"
  s.license = "MIT"
  s.add_runtime_dependency "xcodeproj"
  s.add_runtime_dependency "slop"
  s.add_runtime_dependency "colorize"
end
