#!/usr/bin/env ruby
require 'pathname'
require 'date'

hostname = `hostname -s`.chomp
BACKUP_ROOT = case hostname 
              when 'medusaprod'
                '/mnt/cnfs/medusa/production/backup'
              when 'medusadev1'
                '/mnt/cnfs/medusa/staging/backup'
              else
                raise RuntimeError, "Unknown medusa host: #{hostname}"
              end
GLACIER_ROOT = '/services/medusa/medusa-glacier'
MEDUSA_SHARED_ROOT = '/services/medusa/medusa-cr-capistrano/shared'

#Back up things from the operational storage to the NCSA storage.
class Backup < Object
  
  def initialize()

  end

  def backup
    backup_rails
    backup_glacier
#    backup_database
  end

  #Rails assets, etc.
  def backup_rails
    with_backup_dir('rails') do |dir, date|
      tar_directories(MEDUSA_SHARED_ROOT, dir, ['config', 'log'], date)
      tar_directories(File.join(MEDUSA_SHARED_ROOT, 'public', 'system'), dir, ['attachments'], date)
      delete_older_than(dir, 7)
    end
  end

  #medusa-glacier logs, etc.
  def backup_glacier
    with_backup_dir('glacier') do |dir, date|
      tar_directories(GLACIER_ROOT, dir, ['config', 'log', 'run'], date)
      delete_older_than(dir, 7)      
    end
  end

  #database backups
  def backup_database
    with_backup_dir('database') do |dir, date|
      system('/usr/bin/pg_dump', '-f', File.join(dir, "medusa_#{date}.sql"), 'medusa')
      delete_older_than(dir, 7)
    end
  end

  def tar_directories(source_root_dir, target_dir, source_dirs, date)
    Dir.chdir(source_root_dir) do
      source_dirs.each do |dir|
        system('tar', '-cf', File.join(target_dir, "#{dir}_#{date}.tar"), dir)
      end
    end
  end

  def delete_older_than(dir, days)
    dir.children.each do |child|
      if child.mtime < days_ago(days)
        child.unlink
      end
    end
  end

  def days_ago(number)
    Time.now - number * 24 * 60 * 60
  end

  def with_backup_dir(directory)
    dir = Pathname.new(File.join(BACKUP_ROOT, directory))
    dir.mkpath
    yield dir, Date.today.to_s
  end

end

Backup.new.backup

