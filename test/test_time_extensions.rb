require 'helper'

class TestTimeExtensions < Test::Unit::TestCase
  
  should "know what a weekend day is" do
    assert( Time.weekday?(Time.parse("April 9, 2010 10:30am")))
    assert(!Time.weekday?(Time.parse("April 10, 2010 10:30am")))
    assert(!Time.weekday?(Time.parse("April 11, 2010 10:30am")))
    assert( Time.weekday?(Time.parse("April 12, 2010 10:30am")))
  end
  
  should "know a weekend day is not a workday" do
    assert( Time.workday?(Time.parse("April 9, 2010 10:45 am")))
    assert(!Time.workday?(Time.parse("April 10, 2010 10:45 am")))
    assert(!Time.workday?(Time.parse("April 11, 2010 10:45 am")))
    assert( Time.workday?(Time.parse("April 12, 2010 10:45 am")))
  end
  
  should "know a holiday is not a workday" do
    BusinessTime::Config.reset
    
    BusinessTime::Config.holidays << Date.parse("July 4, 2010")
    BusinessTime::Config.holidays << Date.parse("July 5, 2010")
    
    assert(!Time.workday?(Time.parse("July 4th, 2010 1:15 pm")))
    assert(!Time.workday?(Time.parse("July 5th, 2010 2:37 pm")))
  end
  
  
  should "know the beginning of the day for an instance" do
    first = Time.parse("August 17th, 2010, 11:50 am")
    expecting = Time.parse("August 17th, 2010, 9:00 am")
    assert_equal expecting, Time.beginning_of_workday(first)
  end
  
  should "know the end of the day for an instance" do
    first = Time.parse("August 17th, 2010, 11:50 am")
    expecting = Time.parse("August 17th, 2010, 5:00 pm")
    assert_equal expecting, Time.end_of_workday(first)
  end

  should "know if instance is during business hours" do
    assert(!Time.during_business_hours?(Time.parse("April 11, 2010 10:45 am")))
    assert(!Time.during_business_hours?(Time.parse("April 12, 2010  8:45 am")))
    assert(Time.during_business_hours?(Time.parse("April 12, 2010  9:45 am")))
  end


  should "know a seconds to an instance" do
    start_time = Time.parse("August 17th, 2010, 8:50 am")
    end_time = Time.parse("August 17th, 2010, 13:00 pm")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 3600 * 4
  end

  should "know a seconds to an instance" do
    start_time = Time.parse("August 17th, 2010, 11:50 am")
    end_time = Time.parse("August 17th, 2010, 13:50 pm")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 7200
  end

  should "know a seconds to an instance" do
    start_time = Time.parse("August 17th, 2010, 17:50 am")
    end_time = Time.parse("August 17th, 2010, 18:50 pm")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 0
  end

  should "know a seconds to an instance in weekend" do
    start_time = Time.parse("August 22th, 2010, 11:50 am")
    end_time = Time.parse("August 22th, 2010, 13:50 pm")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 0
  end

  should "know a seconds to an instance between holidays" do
    start_time = Time.parse("August 22th, 2010, 11:50 am")
    BusinessTime::Config.reset
    
    BusinessTime::Config.holidays << Date.parse("August 24, 2010")
    end_time = Time.parse("August 24th, 2010, 13:50 pm")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 8 * 3600
  end

  should "know a seconds to an other day instance" do
    start_time = Time.parse("August 17th, 2010, 16:00 pm")
    end_time = Time.parse("August 18th, 2010, 9:00 am")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, 3600
  end

  should "know a seconds to an other week instance" do
    start_time = Time.parse("August 17th, 2010, 16:00 pm")
    end_time = Time.parse("August 23th, 2010, 10:00 am")
    expecting = start_time.business_time_left_to(end_time)
    assert_equal expecting, (3600 * 26)
  end

  should "know a seconds to end of business hours" do
    time = Time.parse("August 17th, 2010, 16:00 pm")
    expecting = time.business_time_left_to_end
    assert_equal expecting, 3600
    time = Time.parse("August 17th, 2010, 8:00 am")
    expecting = time.business_time_left_to_end
    assert_equal expecting, 3600 * 8
    time = Time.parse("August 17th, 2010, 18:00 pm")
    expecting = time.business_time_left_to_end
    assert_equal expecting, 0
    time = Time.parse("August 21th, 2010, 16:00 pm")
    expecting = time.business_time_left_to_end
    assert_equal expecting, 0
  end

  should "know a seconds from beginning of business hours" do
    time = Time.parse("August 17th, 2010, 16:00 pm")
    expecting = time.business_time_passed_from_beginning
    assert_equal expecting, 3600 * 7
    time = Time.parse("August 17th, 2010, 8:00 am")
    expecting = time.business_time_passed_from_beginning
    assert_equal expecting, 0
    time = Time.parse("August 17th, 2010, 18:00 pm")
    expecting = time.business_time_passed_from_beginning
    assert_equal expecting, 3600 * 8
    time = Time.parse("August 21th, 2010, 16:00 pm")
    expecting = time.business_time_passed_from_beginning
    assert_equal expecting, 0
  end
  
end
