class SummariesController < ApplicationController
  # GET /summaries
  def index
    @candidates = Candidate.order(votes_count: :desc, id: :asc)
  end
end