require "grammars/version"
require 'active_support'

module Grammars
  extend ActiveSupport::Autoload

  autoload :Rule

  def self.rules
    @rules ||= []
  end

  def self.add(original, pos)
    self.rules << Rule.new(original, pos)
  end


  def self.register(&block)
    class_eval(&block)
  end

  def self.parse(text)
    return identify_grammar(self.tag(text))
  end

  def self.identify_grammar(tagged_text)
    tagged_text.map { |tag| tag.values.first }.join(' ')
  end

  def self.tag(raw, rules = self.rules)
    return [] if raw.empty?
    return [{ raw.strip => raw.strip }] if rules.empty?

    matches = raw.match(rules.first.matcher)
    # no matches, just process the next rule

    return tag(raw, rules[1..-1]) if matches.nil?

    before, after = raw.split(matches[0], 2)

    tag(before.strip, rules) +
    [{ matches[0] => rules.first.token }] +
    tag(after.strip, rules)
  end

  def self.generate_frequencies(input_file, output_file)
    output = File.open(output_file, 'w')
    out = []
    File.readlines(input_file).each do |line|
      out << self.parse(line)
    end
    output.puts(self.freq(out))
    output.close
  end

  def self.freq(array)
    freq_hash = Hash.new(0)
    array.each do |e|
      freq_hash[e] += 1
    end
    return freq_hash.sort_by {|k,v| v}.reverse
  end

  def self.find_examples(input_file, output_file, grammar, limit = 1234567890)
    File.open(output_file, 'w') do |f|
      count = 0
      File.readlines(input_file).each do |line|
        if (self.parse(line) == grammar)
            f.puts(line)
            count += 1
        end
        break if count >= limit
      end
    end
  end
end
