
require 'test/unit'


# A helper for testing Asterisk AGI scripts. It interfaces with the
# AGI script in the same way as Asterisk would, and uses test/unit to
# assert that the (send, expect) script it is given behaves as
# specified. It is useful for regression testing and test driven
# development. The AGI script does not have to be implemented in Ruby.


class AsynchronousAsteriskTest < Test::Unit::TestCase

  def init(agi_script, args, test_script)
    @agi_script = IO.popen(agi_script << " " << args.join(sep=' '), 'w+')
    @test_script = test_script
  end
  
  def run_script
    for tx, rx in @test_script
      send(tx)
      response = receive
      assert_equal(rx, response)
    end
    hang_up
  end

  def send(message)
    @agi_script.puts(message)
    @agi_script.flush
  end

  def receive
    @agi_script.readline.strip()
  end

  def hang_up
    Process.kill('TERM', @agi_script.pid)
    true
  end

  # This is a workaround for the fact that Test::Unit requires at
  # least one test method in every test class. 
  def test_nothing; end

end


class ExampleTest < AsynchronousAsteriskTest
  
  def test_answer_and_hangup
    test_script = 
      [["\n", "ANSWER"],
       ["200 result=0", "HANGUP"],
      ]
    init('./example.agi', [], test_script)
    run_script
  end

end

