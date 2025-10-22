class VotesController < ApplicationController
  before_action :set_vote, only: %i[ destroy ]
  after_action -> { Vote.broadcast_summaries }, only: %i[ create destroy ]

  # GET /votes
  def index
    @votes = Vote.eager_load(:candidate).order(created_at: :desc, id: :desc)
    @vote = Vote.new
    @candidates = Candidate.order(:id)
  end

  # POST /votes
  def create
    Vote.create!(vote_params)
    redirect_to votes_path
  end

  # DELETE /votes/1
  def destroy
    @vote.destroy!
    redirect_to votes_path, status: :see_other
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def vote_params
      params.expect(vote: [ :candidate_id ])
    end
end
