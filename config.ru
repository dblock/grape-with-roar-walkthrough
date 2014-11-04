$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'roar/representer'
require 'roar/representer/json'
require 'roar/representer/json/hal'

require 'api'
require 'models/spline'
require 'presenters/spline_presenter'
require 'presenters/splines_presenter'
require 'presenters/root_presenter'

run Api
