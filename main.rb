require 'open3'
require 'pathname'

# def env_has_key(key)
#   return (ENV[key] != nil && ENV[key] !="") ? ENV[key] : abort("Missing #{key}.")
# end

project_path = ENV["AC_PROJECT_PATH"] || abort('Missing project path.')
repository_path = ENV["AC_REPOSITORY_DIR"]
pod_file_exist = ENV['AC_PODFILE_EXIST']
pod_repo_update = ENV['AC_POD_REPO_UPDATE']

cocoapods_version = (ENV["AC_COCOAPODS_VERSION"] != nil && ENV["AC_COCOAPODS_VERSION"] !="") ? ENV["AC_COCOAPODS_VERSION"] : nil

project_dir_path = repository_path ? (Pathname.new repository_path).join(File.dirname(project_path)) : File.dirname(project_path)
cocoapods_podfile_path = File.join(project_dir_path,"Podfile")
cocoapods_podfilelock_path = File.join(project_dir_path,"Podfile.lock")
cocoapods_project_path = File.join(project_dir_path,"Pods","Pods.xcodeproj")

unless File.exist?(cocoapods_podfile_path)
    puts "Podfile does not exists."
    exit 0
end

if File.extname(project_path) != ".xcworkspace"
    puts "Project extension must be xcworkspace."
    exit 0
end

if pod_file_exist 
  if File.exist?(cocoapods_project_path)
      puts "Pods already installed."
      exit 0
  end
end

def runCommand(command)
    puts "@@[command] #{command}"
    unless system(command)
      exit $?.exitstatus
    end
end

if cocoapods_version.nil?
  if File.exist?(cocoapods_podfilelock_path)
    versionArray = File.read(cocoapods_podfilelock_path).scan(/(?<=COCOAPODS: )(.*)/)[0]
    if versionArray && versionArray[0]
      cocoapods_version = versionArray[0]
      puts "Podfile.lock version = #{cocoapods_version}"
      if `which rbenv`.empty?
        runCommand("sudo gem install cocoapods -v #{cocoapods_version} --no-document")
      else
        runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
      end
    end
  end
else
  puts "Cocoapods version = #{cocoapods_version}"
  if `which rbenv`.empty?
    runCommand("sudo gem install cocoapods -v #{cocoapods_version} --no-document")
  else
    runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
  end
end

unless cocoapods_version.nil?
  runCommand("pod _#{cocoapods_version}_ setup")
  if pod_repo_update
    runCommand("pod _#{cocoapods_version}_ repo update")
  end
else
  runCommand("pod --version")
  if pod_repo_update
    runCommand("pod repo update")
  end
end

Dir.chdir(project_dir_path) do
    command = "pod"
    unless cocoapods_version.nil?
      command += " _#{cocoapods_version}_"
    end
    command += " install"
    runCommand(command)
end

exit 0