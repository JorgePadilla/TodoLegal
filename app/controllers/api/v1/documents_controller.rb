class Api::V1::DocumentsController < ApplicationController
  protect_from_forgery with: :null_session
  include ApplicationHelper
  before_action :doorkeeper_authorize!, :document_exists!, only: [:get_document]
  
  def get_document
    user = User.find_by_id(doorkeeper_token.resource_owner_id)
    json_document = get_document_json

    if @document.original_file.attached?
      json_document = json_document.merge(file: url_for(@document.original_file))
    else
      json_document = json_document.merge(file: "")
    end
    render json: {"document": json_document,
      "tags": get_document_tags,
      "related_documents": get_related_documents
    }
  end
  
  def get_documents
    limit = 100
    if !params["limit"].blank?
      limit = params["limit"]
    end
    query = "*"
    if !params["query"].blank?
      query = params["query"]
    end
    from = nil
    to = nil
    if !params["from"].blank?
      begin
        Date.parse(params["from"])
        from = params["from"]
      rescue ArgumentError
      end
    end
    if !params["to"].blank?
      begin
        Date.parse(params["to"])
        to = params["to"]
      rescue ArgumentError
      end
    end
    documents = Document.search(
      query,
      fields: [:name, :publication_number, :description],
      where:
      {
        publication_date: {gte: from, lte: to},
        name: {not: "Gaceta"},
      },
      limit: limit,
      offset: params["offset"].to_i,
      order: {publication_date: :desc})

    total_count = documents.total_count
    documents = documents.to_json
    documents = JSON.parse(documents)

    documents.each do | document |
      tags = []
      document_tags = DocumentTag.where(document_id: document["id"].to_i)
      if document_tags.first
        puts document_tags.first.tag.name
      end
      document_tags.each do |document_tag|
        if document_tag
          tags.push({"name": document_tag.tag.name, "type": document_tag.tag.tag_type.name})
        end
      end
      document["tags"] = tags
    end

    render json: { "documents": documents, "count": total_count }
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    @document = Document.find_by_id(params[:id])
    user_document_visit_tracker = get_user_document_visit_tracker
    can_access = can_access_documents user_document_visit_tracker

    json_document = get_document_json
    if can_access and @document.original_file.attached?
      json_document = json_document.merge(file: url_for(@document.original_file))
    else
      json_document = json_document.merge(file: "")
    end

    {json: {"document": json_document,
        "tags": get_document_tags,
        "related_documents": get_related_documents,
        "downloads": user_document_visit_tracker.visits,
        "can_access": can_access
      }}
  end

protected
  def get_document_json
    related_documents = Document.where(publication_number: @document.publication_number)
    json_document = @document.as_json
    return json_document
  end

  def get_document_tags
    tags = []
    @document.tags.each do |tag|
      tags.push({"name": tag.name, "type": tag.tag_type.name})
    end
    return tags
  end

  def get_related_documents
    Document.where(publication_number: @document.publication_number)
  end

  def document_exists!
    @document = Document.find_by_id(params[:id])
    if !@document
      render json: {"error": "Document not found."}
      return
    end
  end
end
