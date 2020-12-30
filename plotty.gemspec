
require_relative "lib/plotty/version"

Gem::Specification.new do |spec|
	spec.name = "plotty"
	spec.version = Plotty::VERSION
	
	spec.summary = "Draw graphs from data gathered by executing commands"
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/plotty"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["plotty"]
	
	spec.add_dependency "samovar", "~> 2.0"
	spec.add_dependency "tty-screen"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
