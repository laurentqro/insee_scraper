require_relative 'lib/insee_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "insee_scraper"
  spec.version       = InseeScraper::VERSION
  spec.authors       = ["Laurent Curau"]
  spec.email         = ["laurent@thecodeshed.dev"]

  spec.summary       = %q{Insee Scraper}
  spec.description   = %q{A script to scrape BT data from Insee}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
