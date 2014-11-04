class Api < Grape::API
  format :json

  desc 'Root of the Hypermedia API.'
  get do
    present self, with: RootPresenter
  end

  resource :splines do
    desc 'Return a spline.'
    get ':uuid' do
      present Spline.new(uuid: params[:uuid]), with: SplinePresenter
    end

    desc 'Return a few splines.'
    get do
      present 5.times.map { Spline.new }, with: SplinesPresenter
    end
  end
end
