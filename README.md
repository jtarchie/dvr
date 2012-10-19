# Introduction

An experiment to see if database connections can be recorded for playback within RSpec. Following the same patterns of VCR (for HTTP) we record the SQL statements that your database connect records.

# Usage
    > gem install dvr

    require 'dvr'

    cassette_name = "recorded"

    # for recording use :all
    DVR.record :all, cassette_name do
      Person.count.should == 0
    end

    # for playback use :none
    DVR.record :none, cassette_name do
      Person.count.should == 0
    end

# Results

Is it worth it? No.

* Using sqlite3 in memory, the difference in timing is minimal.
* Using sqlite3 with file, the difference is 50% speed up.

I have not tested against anything besides sqlite3, mainly for the ease of setup.

What problem have I encountered that makes this unuseful. Dates and times. If you are running a test that uses date and time and not using a tool like Timecop, you are going to run into some problems.
