# frozen_string_literal: true

require 'open3'
require 'pathname'

project_path = ENV['AC_PROJECT_PATH'] || abort('Missing project path.')
repository_path = ENV['AC_REPOSITORY_DIR']

cocoapods_version = !ENV['AC_COCOAPODS_VERSION'].nil? && ENV['AC_COCOAPODS_VERSION'] != '' ? ENV['AC_COCOAPODS_VERSION'] : nil

project_dir_path = repository_path ? (Pathname.new repository_path).join(File.dirname(project_path)) : File.dirname(project_path)
cocoapods_podfile_path = File.join(project_dir_path, 'Podfile')

unless File.exist?(cocoapods_podfile_path)
  puts 'Podfile does not exists.'
  exit 0
end

if File.extname(project_path) != '.xcworkspace'
  puts 'Project extension must be xcworkspace.'
  exit 0
end

def runCommand(command)
  puts "@@[command] #{command}"
  return if system(command)

  exit $?.exitstatus
end

def podInstall(cocoapods_version, project_dir_path)
  cocoapods_cmd_prefix = cocoapods_version ? "pod _#{cocoapods_version}_" : 'pod'

  Dir.chdir(project_dir_path) do
    runCommand("#{cocoapods_cmd_prefix} install")
  end
end

if cocoapods_version.nil?
  puts 'Using System Default pod version.'
  runCommand('pod --version')
  runCommand('pod repo update')
  Dir.chdir(project_dir_path) do
    runCommand('pod install')
  end
else
  puts "Cocoapods version = #{cocoapods_version}"
  if `which rbenv`.empty?
    runCommand("sudo gem install cocoapods -v #{cocoapods_version} --no-document")
  else
    runCommand("gem install cocoapods -v #{cocoapods_version} --no-document")
  end
  runCommand("pod _#{cocoapods_version}_ setup")
  podInstall(cocoapods_version, project_dir_path)
end

exit 0
