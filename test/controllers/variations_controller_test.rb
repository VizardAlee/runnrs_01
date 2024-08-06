require "test_helper"

class VariationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get variations_new_url
    assert_response :success
  end

  test "should get create" do
    get variations_create_url
    assert_response :success
  end
end
