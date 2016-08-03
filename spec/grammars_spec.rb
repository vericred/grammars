require 'spec_helper'

describe Grammars do
  before :all do
    BarRule = Class.new do
      def self.matcher
        /bar/
      end
    end

    Grammars.register do
      add /abc/, :foo
      add BarRule, :bar
      add /baz/, :baz
    end
  end


  it 'registers rules' do
    expect(Grammars.rules.length).to eql 3
  end

  it 'applies rules' do
    text =
      'abc is the first few letters of the alphabet ' \
      'bar is a common programmer word ' \
      'and baz is yet another word'

    result = Grammars.parse(text)

    expect(result).to eql(
      '<FOO> is the first few letters of the alphabet ' \
      '<BAR> is a common programmer word ' \
      'and <BAZ> is yet another word'
    )
  end

  let(:input_file) {'spec/fixtures/foo.txt'}
  let(:output_file) {'tmp/freqencies.txt'}

  it 'generates a freqencies file' do
    File.delete(output_file) if File.exists?(output_file)
    Grammars.generate_frequencies('spec/fixtures/foo.txt', output_file)
    expect(File).to exist(output_file)
    f = File.readlines(output_file)
    expect(f[0]).to eql("<FOO> <BAR>\n")
    expect(f[1]).to eql("2\n")
  end

  let(:examples_file) {'tmp/examples.out'}

  it 'finds examples' do
    File.delete(examples_file) if File.exists?(examples_file)
    Grammars.find_examples(input_file, examples_file, "<FOO> <BAR>")
    f = File.readlines(examples_file)
    expect(f[0]).to eql ("abc bar\n")
  end
end
