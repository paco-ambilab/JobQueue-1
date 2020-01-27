Pod::Spec.new do |s|
  s.name         = "JobQueue"
  s.version      = "0.0.24"
  s.summary      = "A persistent and flexible job queue for Swift applications"
  s.description  = <<-DESC
  JobQueue is a persistent job queue with a simple API that does not depend on `Operation`/`OperationQueue`, is storage agnostic, supports for manual execution order, per job type concurrency limits, delayed jobs, and more.
                   DESC

  s.homepage     = "https://github.com/Tundaware/JobQueue"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "George Cox" => "george@tundaware.com" }
  s.social_media_url   = "https://twitter.com/Tundaware"

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '4.0'
  s.osx.deployment_target = '10.13'

  s.source = {
    :git => "https://github.com/Tundaware/JobQueue.git",
    :tag => s.version.to_s
  }
  s.swift_version = '5.1'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/**/*.swift'
    ss.dependency 'ReactiveSwift', '~> 6.2.0'
  end
  s.subspec 'Queue' do |ss|
    ss.source_files = 'Sources/Queue/**/*.swift'
    ss.dependency 'JobQueue/Core'
    ss.dependency 'ReactiveSwift', '~> 6.2.0'
  end
  s.subspec 'Storage' do |ss|
    ss.subspec 'InMemory' do |sss|
      sss.source_files = 'Sources/Storage/InMemory/**/*.swift'
      sss.dependency 'JobQueue/Core'
      sss.dependency 'ReactiveSwift', '~> 6.2.0'
    end
    ss.subspec 'CoreData' do |sss|
      sss.source_files = 'Sources/Storage/CoreData/**/*.swift'
      sss.dependency 'JobQueue/Core'
      sss.dependency 'ReactiveSwift', '~> 6.2.0'
    end
  end
end
