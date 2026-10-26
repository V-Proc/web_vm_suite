# frozen_string_literal: true


class DashboardController < ApplicationController
  def show
    render "dashboard/show", layout: "application"
  end
end
