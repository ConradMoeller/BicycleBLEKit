Pod::Spec.new do |spec|

  spec.name         = "BicycleBLEKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of BicycleBLEKit."

  spec.description  = <<-DESC
  This POD provides an API to easily access bicycle specific BLE units.
                   DESC

  spec.homepage     = "http://www.conrad-cycling.com"

  spec.license      = "MIT"

  spec.author             = { "Conrad Moeller" => "info@conrad-cycling.com" }

  spec.ios.deployment_target = "13.2"
  spec.swift_version = "4.2"

  spec.source       = { :git => "https://github.com/ConradMoeller/BicycleBLEKit.git", :tag => "#{spec.version}" }

  spec.source_files  = "BicycleBLEKit/**/*.{h,m,swift}"

end
