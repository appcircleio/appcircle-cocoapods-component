require 'open3'
require 'pathname'

project_path = ENV["AC_PROJECT_PATH"] || abort('Missing project path.')
repository_path = ENV["AC_REPOSITORY_DIR"]

cocoapods_version = (ENV["AC_COCOAPODS_VERSION"] != nil && ENV["AC_COCOAPODS_VERSION"] !="") ? ENV["AC_COCOAPODS_VERSION"] : nil

project_dir_path = repository_path ? (Pathname.new repository_path).join(File.dirname(project_path)) : File.dirname(project_path)
cocoapods_podfile_path = File.join(project_dir_path,"Podfile")
cocoapods_podfilelock_path = File.join(project_dir_path,"Podfile.lock")
# cocoapods_project_path = File.join(project_dir_path,"Pods","Pods.xcodeproj")

unless File.exist?(cocoapods_podfile_path)
    puts "Podfile does not exists."
    exit 0
end

if File.extname(project_path) != ".xcworkspace"
    puts "Project extension must be xcworkspace."
    exit 0
end

# if File.exist?(cocoapods_project_path)
#     puts "Pods already installed."
#     exit 0
# end

def runCommand(command)
    puts "@[command] #{command}"
    status = nil
    stdout_str = nil
    stderr_str = nil
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      stdout.each_line do |line|
        puts line
      end
      stdout_str = stdout.read
      stderr_str = stderr.read
      status = wait_thr.value
    end
  
    unless status.success?
      raise stderr_str
    end
end

if cocoapods_version.nil?
  if File.exist?(cocoapods_podfilelock_path)
    versionArray = File.read(cocoapods_podfilelock_path).scan(/(?<=COCOAPODS: )(.*)/)[0]
    if versionArray && versionArray[0]
      cocoapods_version = versionArray[0]
      puts "Podfile.lock version = #{cocoapods_version}"
      runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
    end
  end
else
  puts "Cocoapods version = #{cocoapods_version}"
    runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
end

if cocoapods_version.nil?
  runCommand("pod --version")
end

Dir.chdir(project_dir_path) do
    command = "pod"
    unless cocoapods_version.nil?
      command += " _#{cocoapods_version}_"
    end
    command += " install"
    command += " --repo-update"
    runCommand(command)
end

exit 0




