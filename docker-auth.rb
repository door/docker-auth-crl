#!/usr/bin/env ruby

require 'socket'
require 'webrick'

class DockerAuth < Sinatra::Base
  post '/Plugin.Activate' do
    '{"Implements": ["authz"]}'
  end
end
