require 'spec_helper'

describe DVR do
  with_model :Person do
    table do |t|
      t.string :name
      t.timestamps
    end
  end

  it "should have Person model" do
    Person.should be
  end

  context "when recording on the DVR" do
    context "when counting records on Person" do
      let(:filename) { File.join(DVR.fixtures_path, "#{cassette_name}.dat") }
      let(:output) { Marshal.load(File.read(filename)) }

      context "when recording new entries" do
        let(:cassette_name) { "all" }
        before do
          DVR.record :all, cassette_name do
            Person.count.should == 0
          end
        end

        context "the cassette file" do
          it "exists" do
            File.exists?(filename).should be_true
          end

          it "has recorded content" do
            output.should be

            output.size.should == 4
            recording = output.last

            recording[:method_name].should == :exec_query
            recording[:arguments].should == ["SELECT COUNT(*) FROM \"#{Person.table_name}\" ", nil, []]
            recording[:return].to_hash.should == ActiveRecord::Result.new(
              ["COUNT(*)"],
              [[0]]
            ).to_hash
          end
        end
      end

      context "when playing back" do
        let(:cassette_name) { "none" }
        before do
          DVR.record :all, cassette_name do
            Person.count.should == 0
          end
        end

        it "uses the value stored in the file" do
          DVR.record :none, cassette_name do
            Person.count.should == 0
          end

          Person.create!(:name => "Hello World")

          DVR.record :none, cassette_name do
            Person.count.should == 0
          end
        end

        it "raises an error when a cannot find SQL to playback" do
          expect {
            DVR.record :none, cassette_name do
              Person.create(:name => "Hello World")
            end
          }.to raise_exception(DVR::NotRecorded)
        end
      end
    end
  end
end
