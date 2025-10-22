module SummariesHelper
  def format_candidates_to_json(candidates)
    {
      labels: candidates.map(&:name),
      datasets: [
        {
          label: "# of Votes",
          data: candidates.map(&:votes_count),
          backgroundColor: candidates.map(&:faded_color),
          borderColor: candidates.map(&:solid_color),
          borderWidth: 1
        }
      ]
    }
  end
end
