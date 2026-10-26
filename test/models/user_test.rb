# frozen_string_literal: true


require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "роль ограничена списком ROLES" do
    user = users(:alice)
    user.role = "superhacker"
    assert_not user.valid?
    user.role = "member"
    assert user.valid?
  end

  test "member_of? определяет принадлежность к воркгруппе" do
    alice = users(:alice)
    assert alice.member_of?(workgroups(:alpha))
    assert_not alice.member_of?(workgroups(:beta))
  end

  test "login должен быть уникальным" do
    user = User.new(workgroup: workgroups(:alpha), login: users(:bob).login, role: "member")
    assert_not user.valid?
  end
end
