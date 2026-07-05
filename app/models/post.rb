class Post < ApplicationRecord
  belongs_to :board
  belongs_to :user
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user

  enum :status, { open: 0, planned: 1, in_progress: 2, done: 3, closed: 4 }, default: :open

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 2000 }

  scope :roadmap, -> { where(status: [ :planned, :in_progress, :done ]) }
  scope :popular, -> { order(votes_count: :desc, created_at: :desc) }

  STATUS_LABELS = {
    "open"        => "Under review",
    "planned"     => "Planned",
    "in_progress" => "In progress",
    "done"        => "Done",
    "closed"      => "Closed"
  }.freeze

  def status_label = STATUS_LABELS.fetch(status, status.humanize)

  def voted_by?(user)
    return false unless user
    votes.exists?(user_id: user.id)
  end
end
