# Idempotent sample data for local development.
# Run with: bin/rails db:seed

demo = User.find_or_create_by!(email_address: "demo@loopline.app") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

board = Board.find_or_create_by!(slug: "loopline-feedback") do |b|
  b.user = demo
  b.name = "Loopline Feedback"
  b.description = "Help shape the product — post ideas and vote."
end

[
  { title: "Dark mode",          description: "Please add a dark theme.",                 status: :planned },
  { title: "Slack integration",  description: "Notify a channel on new feedback.",         status: :open },
  { title: "CSV export",         description: "Export all feedback for a board as CSV.",    status: :in_progress },
  { title: "Email digests",      description: "Weekly summary of top-voted ideas.",         status: :done }
].each do |attrs|
  post = board.posts.find_or_create_by!(title: attrs[:title]) do |p|
    p.user = demo
    p.description = attrs[:description]
    p.status = attrs[:status]
  end
  post.votes.find_or_create_by!(user: demo)
end

puts "Seeded: #{User.count} users, #{Board.count} boards, #{Post.count} posts, #{Vote.count} votes."
