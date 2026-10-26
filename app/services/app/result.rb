# frozen_string_literal: true


module App
  class Result
    def initialize(success:, value: nil, errors: [])
      @success = success
      @value = value
      @errors = errors
    end

    def success?
      @success
    end

    def failure? = !success?

    def value = @value

    def errors = @errors

    def self.ok(value) = new(success: true, value: value)

    def self.fail(*messages) = new(success: false, errors: messages)
  end
end
