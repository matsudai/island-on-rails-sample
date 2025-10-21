class SummariesController < ApplicationController
  # GET /summaries
  def index
    @candidates = Candidate.all
  end
end

