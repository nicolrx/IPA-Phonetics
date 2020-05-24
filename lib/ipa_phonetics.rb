require "ipa_phonetics/version"
require "ipa_phonetics/special_chars"

module IpaPhonetics
  class Error < StandardError; end
	
	require "json"
	require "timeout"

	@timeout = 1

	ROOT = File.expand_path('../', File.dirname(__FILE__))

	def IpaPhonetics.parseCSV(path)
		Hash[File.open("#{ROOT}/data/#{path}.csv").read.split("\n").map {|ligne| ligne.split("#")}]
	end

	def IpaPhonetics.exceptions
		@exceptions ||= JSON.parse(File.read("#{ROOT}/data/dict.json"))
	end

	def IpaPhonetics.conversion
		@conversion ||= parseCSV "conversion"
	end

	def IpaPhonetics.set_timeout(seconds)
		@timeout = seconds
	end
	
	def IpaPhonetics.timeout
		@timeout
	end

	def IpaPhonetics.get(text)
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
