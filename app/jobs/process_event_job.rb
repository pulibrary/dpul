# frozen_string_literal: true

class ProcessEventJob < ApplicationJob
  def perform(msg)
    msg = JSON.parse(msg)
    FiggyEventProcessor.new(msg).process
  end
end
