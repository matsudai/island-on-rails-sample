class Vote < ApplicationRecord
  belongs_to :candidate, counter_cache: true

  def self.broadcast_summaries
    candidates = Candidate.order(votes_count: :desc, id: :asc)

    Turbo::StreamsChannel.broadcast_replace_to(
      "summaries",
      target: "summaries_table",
      partial: "summaries/summaries_table",
      locals: { candidates: }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "summaries",
      target: "summaries-chart-data",
      partial: "summaries/chart_data",
      locals: { candidates: }
    )

    Turbo::StreamsChannel.broadcast_action_to(
      "summaries",
      action: "dispatch_event",
      target: "summaries-chart-data",
      attributes: { 
        "event-name": "summaries:change",
        "event-detail": {}.to_json
      }
    )
  end
end
