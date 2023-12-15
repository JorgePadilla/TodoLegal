class Document < ApplicationRecord
  include PgSearch
  searchkick language: 'light_spanish'

  has_many :issuer_document_tags, :dependent => :destroy
  has_many :document_tags, :dependent => :destroy
  has_many :tags, through: :document_tags, :dependent => :destroy
  has_one :judgement_auxiliary

  belongs_to :document_type

  has_one_attached :original_file

  def search_data
    {
      # name: name,
      issue_id: issue_id,
      # short_description: short_description,
      # description: description,
      # publication_date: publication_date,
      # publication_number: publication_number,
      # issuer_document_tags: issuer_document_tags.map(&:tag_name),
      # document_type_name: document_type&.name,
      # document_type_alternative_name: document_type&.alternative_name,
      # document_tags: document_tags.map(&:tag_name)
    }
  end

  pg_search_scope :search_by_all,
                  against: [:name, :description, :publication_number],
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: "spanish"
                    }
                  }

  def generate_friendly_url
    [name.parameterize.tr('-',''), publication_number.parameterize.tr('-','')].join('-')
  end
end
