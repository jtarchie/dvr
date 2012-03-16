require 'spec_helper'
require 'benchmark'

describe "Benchmarking" do
  REPEAT = 10

  with_model :Person do
    table do |t|
      t.string :name
    end
  end

  def time(&block)
    Benchmark.realtime do
      REPEAT.times { |i| block.call(i) }
    end
  end

  it "should be faster than normal database" do
    block = Proc.new do |i|
      person = Person.create(:name => i)
      Person.find(person.id)
    end

    # warm up cassette
    DVR.record :all, "benchmark" do
      REPEAT.times &block
    end

    # time it
    gen_time = nil
    DVR.record :none, "benchmark" do
      gen_time = time &block
    end

    #time it without recording
    natural_time = time &block

    ap :gen_time => gen_time,
        :natural_time => natural_time

    gen_time.should < natural_time
  end
end
