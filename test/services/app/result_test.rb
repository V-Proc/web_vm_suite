# frozen_string_literal: true


require "test_helper"

class ResultTest < ActiveSupport::TestCase
  test "ok -> success?, value" do
    r = App::Result.ok(42)
    assert r.success?
    assert_equal 42, r.value
    assert_equal [], r.errors
  end

  test "fail -> failure?, errors" do
    r = App::Result.fail("ошибка")
    assert r.failure?
    assert_equal ["ошибка"], r.errors
  end
end
