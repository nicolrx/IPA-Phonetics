require "ipa_phonetics/version"
require "ipa_phonetics/special_chars"

module IpaPhonetics
  class Error < StandardError; end
	
	require "json"
	require "timeout"

	@timeout = 1

	def self.parseCSV(path)
		Hash[File.open("#{ROOT}/data/#{path}.csv").read.split("\n").map {|ligne| ligne.split("#")}]
	end

	def self.exceptions
		@exceptions ||= JSON.parse(File.read("#{ROOT}/data/dict.json"))
	end

	def self.conversion
		@conversion ||= parseCSV "conversion"
	end

	def self.set_timeout(seconds)
		@timeout = seconds
	end
	
	def self.timeout
		@timeout
	end

	def self.get(text)
		text = text.downcase
		text.gsub(SPE, "").split.map do |word|
			exceptions[word] || "".tap do |result|
				Timeout::timeout(timeout) do
					conversion.select { |rule| word =~ /#{rule}/ }.first.tap do |rule, api|
						word.sub! /#{rule}/, ""
						result << api.to_s
					end until word.empty?
				end
			end
		end
	rescue Timeout::Error
		return []
	end
	
end
