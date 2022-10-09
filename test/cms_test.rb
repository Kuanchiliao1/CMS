ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "minitest/reporters"
require "rake"
Minitest::Reporters.use!

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal(200, last_response.status)
  end

  def test_history
    get "/history.txt"
  end

  def test_file_not_found
    get "/file_does_not_exist.txt"
    
    # assert_equal(200, last_response.status)
    # Instead, use 302 to assert the user was directed
    assert_equal(302, last_response.status)

    # Request page that user was redirected to
    get last_response["Location"]

    # Validate the error message
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "file_does_not_exist.txt does not exist")

    # Check that the error message disappears
    get "/"
    refute_includes(last_response.body, "file_does_not_exist.txt does not exist")
  end

  def test_render_markdown
    get "/about.md"

    assert_equal(200, last_response.status)

    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    
    assert_equal("<h1>Ruby is...</h1>\n\n<p>A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.</p>\n", last_response.body )
  end

  def test_edit_file

  end
end