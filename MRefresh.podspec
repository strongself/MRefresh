Pod::Spec.new do |spec|
  
  spec.name         = "MRefresh"
  spec.version      = "0.2.0"
  spec.summary      = "This pod enables you to add pull-to-refresh mechanism to your scrollviews and tableviews and use svg patterns in your refreshing views layers.'"
  spec.homepage     = "https://github.com/strongself/MRefresh"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Mikhail Rakhmanov" => "rakhmanov.m@gmail.com" }
  spec.platform     = :ios
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/strongself/MRefresh.git", :tag => "#{spec.version}" }

  spec.source_files  = "MRefresh/**/*.{h,m,swift}"
end
