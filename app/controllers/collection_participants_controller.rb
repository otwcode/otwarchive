class CollectionParticipantsController < ApplicationController
  before_filter :load_collection
  
  def index
    @collection_participants = @collection.collection_participants
  end
  
  def update
    @participant = CollectionParticipant.find(params[:id])
  end
end
