require 'bundler'
Bundler.require

require_relative 'lib/app/scapper'

email = Scappeur.new
 
email.json
email.save_as_spreadsheet
email.save_as_csv

