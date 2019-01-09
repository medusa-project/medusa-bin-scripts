#!/usr/bin/env ruby

require 'liquid'

Liquid::Template.error_mode = :strict

common_vars = Hash.new.tap do |h|
  env_vars = %w(monit_contact monit_mailserver user
                home fixity_server_home fits_server_home medusa_home
                )
  env_vars.each do |var|
    h[var] = ENV[var.upcase]
  end
end

Dir.chdir(File.join(ENV['HOME'], 'bin/etc')) do 
  Dir['*.liquid'].each do |template_file|
    template = Liquid::Template.parse(File.read(template_file))
    target = template_file.sub(/\.liquid$/, '')
    File.open(target, 'w') do |f|
      f.puts template.render!(common_vars, strict_variables: true)
    end
  end
end
