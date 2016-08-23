class ApiMeasuresController < BaseApiController
  before_filter :find_measure, only: [:show, :update]

  before_filter only: :create do
    unless @json.has_key?('measure') && @json['measure'].responds_to?(:[]) && @json['measure']['name']
      render nothing: true, status: :bad_request
    end
  end

  before_filter only: :update do
    unless @json.has_key?('measure')
      render nothing: true, status: :bad_request
    end
  end

  before_filter only: :create do
    @measure = Project.find_by_name(@json['measure']['name'])
  end
end