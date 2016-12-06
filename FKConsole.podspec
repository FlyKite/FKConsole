Pod::Spec.new do |s|
  s.name         = "FKConsole"
  s.version      = "1.0.0"
  s.summary      = "A short description of FKConsole."
  s.homepage     = "https://github.com/FlyKite/FKConsole"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "FlyKite" => "DogeFlyKite@gmail.com" }
  s.social_media_url   = "http://blog.fly-kite.com"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/FlyKite/FKConsole.git", :tag => "#{s.version}" }
  s.source_files  = "FKConsole/*.swift"
end