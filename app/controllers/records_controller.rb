class RecordsController < ApplicationController
  respond_to :html, :json, :xml, :pml
  before_action :find_resource, except: [:index]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @records_search = RecordProperty.readables(current_user).where.not(datum_type: ["Chemistry", "Spot"]).search(params[:q])
    @records_search.sorts = "updated_at ASC" if @records_search.sorts.empty?
    @records = @records_search.result.page(params[:page]).per(params[:per_page])
#    respond_with @records, :methods  # TODO: jsonおよびxml表現ではどのような形式で欲しいのか？
    respond_with @records, methods: [:datum_attributes]

  end

  def show
    respond_with @record do |format|
      format.html { redirect_to @record }
      format.json { render json: @record.record_property, methods: [:datum_attributes] }
      format.xml { render xml: @record.record_property, methods: [:datum_attributes] }
    end
  end

# /records/xxxx-xxx/root
  def root
    @root = @record.respond_to?(:root) ? @record.root : []
    respond_with @root do |format|
      format.html { redirect_to @root }
      format.json { render json: @root.record_property, methods: [:datum_attributes] }
      format.xml { render xml: @root.record_property, methods: [:datum_attributes] }
    end
  end

  def parent
    @parent = @record.respond_to?(:parent) ? @record.parent : []
    respond_with @parent do |format|
      format.html { redirect_to @parent }
      format.json { render json: @parent.record_property, methods: [:datum_attributes] }
      format.xml { render xml: @parent.record_property, methods: [:datum_attributes] }
    end
  end

  def casteml
    send_data([@record].to_pml,
              :type => 'application/xml',
              :filename => @record.global_id + '.pml', 
              :disposition=>'attached')    
  end

  def property
    respond_with @record.record_property
  end

# /records/xxxx-xxx/ancestors
  def ancestors
    @records = @record.respond_to?(:ancestors) ? @record.ancestors : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end
# /records/xxxx-xxx/descendants
  def descendants
    @records = @record.respond_to?(:descendants) ? @record.descendants : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end
# /records/xxxx-xxx/descendants
  def self_and_descendants
    @records = @record.respond_to?(:self_and_descendants) ? @record.self_and_descendants : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end

# /records/xxxx-xxx/daughters
  def daughters
    @records = @record.respond_to?(:children) ? @record.children : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end

# /records/xxxx-xxx/siblings
  def siblings
    @records = @record.respond_to?(:siblings) ? @record.siblings : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end

# /records/xxxx-xxx/self_and_siblings
  def self_and_siblings
    @records = @record.respond_to?(:self_and_siblings) ? @record.self_and_siblings : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end

# /records/xxxx-xxx/families
  def families
    @records = @record.respond_to?(:families) ? @record.families : []
    respond_with @records do |format|
      format.json { render json: @records.map(&:record_property), methods: [:datum_attributes] }
      format.xml { render xml: @records.map(&:record_property), methods: [:datum_attributes] }
    end
  end

  
  def destroy
    @record.destroy
    respond_with @record
  end

  private

  def find_resource
    @record = RecordProperty.find_by!(global_id: params[:id]).datum
    authorize!(params[:action], @record)
  end

  def record_not_found(e)
    respond_to do |format|
      format.html { render 'record_not_found', status: :not_found }
      format.all { render nothing: true, status: :not_found }
    end
  end

end
