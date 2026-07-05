class Board < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                             message: "must be lowercase letters, numbers and hyphens" }
  validates :description, length: { maximum: 500 }

  before_validation :generate_slug, on: :create

  def to_param = slug

  private

  def generate_slug
    return if slug.present?

    base = name.to_s.parameterize.presence || SecureRandom.hex(4)
    candidate = base
    counter = 2
    while Board.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
