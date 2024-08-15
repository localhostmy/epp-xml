# -*- encoding: utf-8 -*-
# stub: epp-xml 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "epp-xml"
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Estonian Internet Foundation"]
  s.date = "2023-05-17"
  s.description = "Gem for generating valid XML for EIS Extensible Provisioning Protocol requests"
  s.email = "info@internet.ee"
  s.files = ["lib/client_transaction_id.rb", "lib/epp-xml.rb", "lib/epp-xml/contact.rb", "lib/epp-xml/domain.rb", "lib/epp-xml/keyrelay.rb", "lib/epp-xml/session.rb"]
  s.homepage = "https://github.com/internetee/epp-xml"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "Gem for generating XML for EIS EPP requests"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 4.1"])
      s.add_runtime_dependency(%q<builder>, ["~> 3.2"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.6"])
    else
      s.add_dependency(%q<activesupport>, [">= 4.1"])
      s.add_dependency(%q<builder>, ["~> 3.2"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 4.1"])
    s.add_dependency(%q<builder>, ["~> 3.2"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
  end
end
