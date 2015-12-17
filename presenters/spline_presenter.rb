module SplinePresenter
  include Roar::JSON::HAL
  include Roar::Hypermedia
  include Grape::Roar::Representer

  property :uuid
  property :reticulated

  link :self do
    "http://localhost:9292/splines/#{uuid}"
  end
end
