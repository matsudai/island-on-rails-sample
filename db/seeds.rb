# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Candidates from chart_controller.js color mappings
candidates_data = [
  { name: 'Red', solid_color: 'rgba(255, 99, 132, 1)', faded_color: 'rgba(255, 99, 132, 0.2)' },
  { name: 'Blue', solid_color: 'rgba(54, 162, 235, 1)', faded_color: 'rgba(54, 162, 235, 0.2)' },
  { name: 'Yellow', solid_color: 'rgba(255, 206, 86, 1)', faded_color: 'rgba(255, 206, 86, 0.2)' },
  { name: 'Green', solid_color: 'rgba(75, 192, 192, 1)', faded_color: 'rgba(75, 192, 192, 0.2)' },
  { name: 'Purple', solid_color: 'rgba(153, 102, 255, 1)', faded_color: 'rgba(153, 102, 255, 0.2)' },
  { name: 'Orange', solid_color: 'rgba(255, 159, 64, 1)', faded_color: 'rgba(255, 159, 64, 0.2)' }
]

candidates_data.each do |data|
  Candidate.find_or_create_by!(name: data[:name]) do |candidate|
    candidate.solid_color = data[:solid_color]
    candidate.faded_color = data[:faded_color]
  end
end
