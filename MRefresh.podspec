Pod::Spec.new do |spec|
  
  spec.name         = "MRefresh"
  spec.version      = "0.2.1"
  spec.summary      = "This pod adds pull to refresh to your views with arbitrary svg animations"
  spec.homepage     = "https://github.com/strongself/MRefresh"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Mikhail Rakhmanov" => "rakhmanov.m@gmail.com" }
  spec.ios.deployment_target = "11.0"
  spec.swift_versions = "5.0"
  spec.source       = { :git => "https://github.com/strongself/MRefresh.git", :tag => "#{spec.version}" }

  spec.source_files  = "MRefresh/**/*.{h,m,swift}"
end
