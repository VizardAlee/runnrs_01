require "test_helper"

class TestPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get test_pages_home_url
    assert_response :success
  end
end
